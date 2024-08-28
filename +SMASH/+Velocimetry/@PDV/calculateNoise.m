% calculateNoise Calculate noise spectra
%
% This method calculates noise spectra and time-domain noise (RMS) using
% the reference selection.  
%    object=calculateNoise(object);
% Noise calculations are automatically called (as needed) by the
% generateHistory method.
%
% Manual noise analysis can be used for testing partition settings prior
% to history generation.  The RMS noise value should be similar at all
% analysis durations; changes indicate overlap between positive and
% negative frequency component, i.e. the duration is too small.  Noise
% spectra variations with different partition settings is completely
% normal.
%
% See also PDV, selectReference, generateHistory
%

%
% created February 9, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=calculateNoise(object,Nremove)

assert(strcmpi(object.Status.Reference,'complete'),...
    'ERROR: cannot calculate noise without reference selection');

% manage input
if (nargin < 2) || isempty(Nremove)
    Nremove=1;
end

% perform noise calculations
object.Noise=nan(size(object.Channel));
object.PrivateIdealSpectrum=cell(size(object.Channel));
for n=1:object.NumberChannels
    local=object.Channel{n};
    local.Normalization='none';
    local.Measurement=crop(local.Measurement,object.ReferenceSelection);
    assert(~isempty(local.Measurement.Grid),...
        'ERROR: reference selection contains no data');           
    local=partition(local,'Points',local.Partition.Points);
    if local.Partition.Blocks > 1000
        old=local.Partition;
        local=partition(local,'Blocks',1000);
        old.Skip=local.Partition.Skip;
        local=partition(local','Points',[old.Points old.Skip]);
    end    
    assert(local.Partition.Blocks > 1,...
        'ERROR: partitions must be smaller than the reference selection');
    spectrum=analyze(local);          
    spectrum=mean(spectrum,'Grid1');
    temp=SMASH.SignalAnalysis.ShortTime(spectrum);   
    width=1/object.Partition.Duration;    
    df(1)=width/10;
    f=temp.Measurement.Grid;   
    df(2)=(f(end)-f(1))/(numel(f)-1);
    if df(2) > df(1)
        N=ceil(df(2)/df(1))*numel(f);
        f=linspace(f(1),f(end),N);
        temp.Measurement=regrid(temp.Measurement,f);
    end      
    temp=partition(temp,'Duration',[10*width width/10]);
    temp=analyze(temp,@(in) median(in.Data));
    temp=split(temp);
    temp=lookup(temp,spectrum.Grid,0);
    spectrum=reset(spectrum,spectrum.Grid,temp);   
    spectrum.GridLabel='Frequency';
    spectrum.DataLabel='Power';
    spectrum.Name='Noise power density';
    object.PrivateNoiseSpectrum{n}=spectrum;
    background=spectrum;
    BGarea=trapz(background.Grid,background.Data);
    % noise calibration 
    t=local.Measurement.Grid;
    local.Measurement=reset(local.Measurement,[],randn(size(t)));
    spectrum=analyze(local); 
    spectrum=mean(spectrum,'Grid1'); 
    area=trapz(spectrum.Grid,spectrum.Data); % white noise energy
    object.Noise(n)=sqrt(BGarea/area(1));
    object.Noise(n)=object.Noise(n)/2; % account for postive/negative frequency integration
    % amplitude calibration
    f0=object.SampleRate(n)/4; % 50% Nyquist limit    
    s=2*cos(2*pi*f0*t+2*pi*rand(1));    
    local.Measurement=reset(local.Measurement,t,s);
    spectrum=analyze(local);
    spectrum=mean(spectrum,'Grid1');
    spectrum=shift(spectrum,-f0);
    object.PrivateIdealSpectrum{n}=spectrum;
end

object=changeStatus(object,'obsolete','History');
object.Status.Noise='complete';

end