% estimateNoise Estimate random noise
%
% This method estimates random noise content of a signal.
%    [sigma,noise]=estimateNoise(object);
% The output "sigma" is the RMS noise level (scalar) in the time domain.
% The output "noise" is the noise power spectrum (Signal object).  These
% results are calculated as follows.
%    -The signal is divided into 50 blocks for STFT analysis.  
%    -Mean noise at each frequency is determined by statistical analysis
%    across all blacks.  In the absence of coherent signal, noise power at
%    each frequency follows an exponential distribution.  
%    -Local median smoothing is used to remove non-random outliers.  The
%    characteristic frequency width of these outliers divided by the
%    total signal duration.  The smoothing region is larger than this width
%    by a factor of 3.
% Optional parameters can be passed to the method to modify noise analysis.
%    [...]=estimateNoise(object,blocks,factor);
% 
% Requesting a third output:
%    [sigma,noise,BW]=estimateNoise(...);
% returns an estimate of the signal's bandwidth.
%
% See also Signal
%

%
% created March 11, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function [sigma,profile,bandwidth]=estimateNoise(object,blocks,factor)

% manage input
default=20;
if (nargin < 2) || isempty(blocks)
    blocks=default;
else
    assert(SMASH.General.testNumber(blocks,'positive','integer','notzero'),...
        'ERROR: over invalid number of analysis blocks');
    if blocks < default
        warning('Number of analysis blocks increased from %d to %d',...
            blocks,default);
        blocks=default;
    end
end

if (nargin < 3) || isempty(factor)
    factor=3;
else
    assert(SMASH.General.testNumber(factor,'positive'),...
        'ERROR: invalid width factor');
    if factor < 3
        warning('Width factors below 3 may overestimate noise');
    end
end

% enforce uniform grid
if ~object.GridUniform
    object=regrid(object);
end
t=object.Grid;
dt=(t(end)-t(1))/(numel(t)-1);
fmax=1/(2*dt);

% generate STFT image
source=SMASH.SignalAnalysis.STFT(object);
source.FFToptions.RemoveDC=false;
source=partition(source,'blocks',blocks);
tau=source.Partition.Duration;
M=round(2*fmax*tau);
source.FFToptions.NumberFrequencies=M;
source.Normalization='none';
result=analyze(source);

% reduce image to profile
frequency=result.Grid2;
x=linspace(0,1,numel(result.Grid1));
index=(x < 0.50);
x=x(:);
basis=-log(1-x);
profile=nan(size(frequency));
for m=1:numel(frequency)
    y=sort(result.Data(m,:));    
    y=y(:);
    param=basis(index)\y(index);
    profile(m)=param;   
end

% remove outliers
source=SMASH.SignalAnalysis.ShortTime(frequency,profile);
source=partition(source,'duration',factor*(4/tau));
result=analyze(source,@(arg) median(arg.Data));
profile=crop(result,[factor*(2/tau) inf]);

% calculate RMS noise
sigma=sqrt(2*trapz(profile.Grid,profile.Data)); % cover positive and negative frequencies
profile.GridLabel='Frequency';
profile.DataLabel='Power density';

if nargout >= 3
    temp=reset(profile,[],log10(profile.Data));    
    temp=differentiate(temp,[1 floor(fmax/frequency(2)/100)]);
    [~,index]=min(temp.Data);
    bandwidth=temp.Grid(index);
end

end