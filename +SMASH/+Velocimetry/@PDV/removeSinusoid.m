% removeSinusoid Remove sinusoid
%
% This method removes a sinusoid:
%     s(t) = A cos(2*pi*f0*t) + B sin(2*pi*f0*t)
% from a PDV measurement.  The amplitudes (A and B) and reference
% frequency (f0) are determined by analyzing a region of the time-frequency
% domain.  This region may be selected interactively:
%    object=removeSinusoid(object); 
% when a complete spectrogram is available.  This region can also be
% explicitly specified.
%    object=removeSinusoid(object,'Time',[t1 t2],'Frequency',[f1 f2]);
% When no frequency bound is specified, the strongest feature from the
% reference region ito estimate the bound.
%    object=removeSinusoid(object,'Time',[t1 t2]);
% This approach is meant for removing an extended baseline, i.e. the
% interference of the reference laser with unshifted light from the target
% laser.
%
% In multi-channel measurements, interative region selection prompts the
% user to select a particular channel for sinusoid removal.  The first
% channel is used by default for explicit region selection; an alternate
% channel can be specified with an additional name/value input.
%    object=removeSinusoid(object,'Channel',index,...);
% Sinusoid removal is always performed one channel at time.
%
% The object returned by this method has the function s(t) subtracted over
% the entire time domain.  The sinusoid parameters [f0 A B] are returned as
% a second output.
%    [object,param]=removeSinusoid(object,...);
%
% See also PDV, selectReference
%

%
% created February 12, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function [object,param]=removeSinusoid(object,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

region=SMASH.ROI.Rectangle('xy');
index=1;
GUI=true;

for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)        
        case 'frequency'
            try
                data=region.Data;
                data(3)=value(1);
                data(4)=value(2);
                region=define(region,data);
            catch ME
                throwAsCaller(ME);
            end
            GUI=false;
        case 'time'
            try
                data=region.Data;
                data(1)=value(1);
                data(2)=value(2);
                region=define(region,data);
            catch ME
                throwAsCaller(ME);
            end
            GUI=false;
        case 'channel'
            assert(isnumeric(value) && any(value==(1:object.NumberChannels)),...
                'ERROR: invalid channel index');
            index=value;
        otherwise
            error('ERROR: invalid option name');
    end
end

% interactive selection
param=[];
if GUI
    assert(strcmpi(object.Status.Spectrogram,'complete'),...
        'ERROR: interactive region selection requires spectrograms');
    if isempty(index)
        valid=1:object.NumberChannels;
        if isscalar(valid)
            index=valid;
        else
            choice=cell(size(object.Channel));
            for n=1:object.NumberChannels
                choice{n}=sprintf('Channel %d',n);
            end
            [index,ok]=listdlg('ListString',choice,...
                'SelectionMode','single','Name','Select channel');
            if ~ok
                return
            end
        end
    end
    view(crop(object.PrivateSpectrogram{index},[],[0 inf]));
    title('Select sinusoid region');
    ylabel('Beat frequency','FontWeight','bold');
    region.Name='Sinusoid region';
    region=select(region,gca);
    delete(gcf); 
end

% sinusoid analysis
local=object.Channel{index}.Measurement;
local=crop(local,region.Data(1:2));

spectrum=fft(local,object.FFToptions);
if any(isinf(region.Data(3:4)))
    reference=object.Channel{index}.Measurement;
    reference=crop(reference,object.ReferenceSelection);
    reference=fft(reference,'NumberFrequencies',1e6);
    report=object.findPeak(reference,...
        'Mode','gaussian','AmplitudeThreshold',0.50);
    data=region.Data;
    data(3)=report.Location-1*report.Width;
    data(4)=report.Location+1*report.Width;
    region=define(region,data);
end
spectrum=crop(spectrum,region.Data(3:4));
report=object.findPeak(spectrum,'Mode','gaussian','AmplitudeThreshold',0.50);
fA=report.Location-report.Width;
fB=report.Location+report.Width;


f0=fminbnd(@residual,fA,fB,...
    optimset('TolX',1e-7,'MaxIter',1e6,'MaxFunEvals',1e6));
[~,amplitude]=residual(f0);
    function [chi2,amplitude,fit]=residual(frequency)
        phase=2*pi*frequency*local.Grid;
        basis=[cos(phase) sin(phase)];
        amplitude=basis\local.Data;
        fit=basis*amplitude;
        chi2=mean((local.Data-fit).^2);
    end

% removal
param=[f0 amplitude(1) amplitude(2)];
time=object.Channel{index}.Measurement.Grid;
fit=amplitude(1)*cos(2*pi*f0*time)+amplitude(2)*sin(2*pi*f0*time);
object.Channel{index}.Measurement=object.Channel{index}.Measurement-fit;

if strcmpi(object.Status.Spectrogram,'complete') % update spectrogram
    temp=object.Channel{index};
    sparam=object.SpectrogramSettings.Partition;
    temp=partition(temp,'Points',[sparam.Points sparam.Skip]);
    temp.Normalization='global';
    result=analyze(temp);
    object.PrivateSpectrogram{index}=result;
end
object=changeStatus(object,'obsolete','noise','history');

end