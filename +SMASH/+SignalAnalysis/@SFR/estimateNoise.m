% estimateNoise Estimate noise content
%
% This method estimates the signal's noise content, updating the Noise
% property.
%    estimateNoise(object);
% Noise analysis is performed by dividing the frequency-domain power
% spectrum into set of non-overlapping blocks.  The median power in each
% block is used to estimate local averages, assuming that values in each
% block are distributed exponentially.  This process removes most coherent
% power content, so integration over all blocks is proportional to the
% time-domain noise.  Compensation is made for digital window effects.
%
% The behavior of this method is controlled with optional name/value pairs.
%    estimateNoise(object,name,value,...);
% Valid options include:
%    -'Blocks', which can be any number > 5 (default is 50).  The maximum
%    number of blocks is determined by the amount of signal data; a warning
%    is generated if the signal is not long enough to support at least 20
%    blocks.  Higher block settings more accurately capture the spectral
%    shape, but at some point the result may contain coherent artifacts.
%    -'Plot' which controls automatic plot generation.  The value can be
%    'on' (default) or 'off'.
%    -'Time', which restricts analysis to a specified time region.  This
%    value must be two-element array indicating the start and stop time.
%    The default value [-inf +inf] uses the entire signal.
%
% See also SFR, plot, estimateAmplitude, estimateBandwidth, setNoise
%
function estimateNoise(object,varargin)

% manage object arrays
if numel(object) > 1
    for n=1:numel(object)
        estimateNoise(object(n),varargin{:});
    end
    return
end

% make sure there is enough signal
t=object.Time;
maxblocks=verifyTotalTime(t(end)-t(1));
    function value=verifyTotalTime(duration)
        safety=5;
        width=2*safety/duration;
        range=object.SampleRate/2;
        value=floor(range/width);
        assert(value > 5,'ERROR: not enough signal for noise estimation');
        if value < 20
            warning('More signal needed for accurate noise estimate');
        end        
    end

% manage input
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');

option=struct('Blocks',[],'Plot','on','Time',[-inf +inf]);
try
    option=SMASH.Developer.options2struct(option,varargin{:});
catch ME
    throwAsCaller(ME);
end

if isempty(option.Blocks)
    option.Blocks=min(50,maxblocks);
else
    assert(testNumber(option.Blocks),...
        'ERROR: invalid number of analysis blocks');
    if option.Blocks > maxblocks
        warning('Reducing blocks from %d to %d due to signal limitations',...
            option.Blocks,maxblocks)
        option.Blocks=maxblocks;
    end
end

if strcmpi(option.Plot,'on')
    option.Plot=true;
elseif strcmpi(option.Plot,'off')
    option.Plot=false;
else
   error('ERROR: plot option must be ''on'' or ''off''');
end

assert(isnumeric(option.Time) && (numel(option.Time) == 2),...
    'ERROR: invalid time range');
option.Time=sort(option.Time);
assert(diff(option.Time) > 0,'ERROR: time range cannot have zero width')
option.Time(1)=max(option.Time(1),t(1));
option.Time(2)=min(option.Time(2),t(end));

%% transform entire signal
total=option.Time(2)-option.Time(1);
verifyTotalTime(total);

keep=(t > option.Time(1)) & (t <= option.Time(2));
signal=object.Signal(keep);
N=numel(signal);
tn=(t(keep)-mean(option.Time))/total;
window=object.Window.Function(tn);
N2=pow2(nextpow2(N)+1);
[f,P]=object.calculateFFT(signal.*window,N2);
f=f*object.SampleRate;

% process blocks
start=linspace(0,f(end),option.Blocks+1);
stop=start(2:end);
start=start(1:end-1);
fit=nan(1,option.Blocks);
fprintf('Analyzing %d spectrum blocks...',option.Blocks);
for n=1:option.Blocks
   index=(f >= start(n)) & (f <= stop(n));
   fit(n)=median(P(index))/log(2);
end
fprintf('done\n');
center=(start+stop)/2;

fi=[0 center f(end)];
Pi=interp1(center,fit,fi,'nearest','extrap');
I1=2*trapz(fi/object.SampleRate,Pi); % 2 accounts for negative frequencies
I2=trapz(tn,window.^2);
RMS=sqrt(I1/I2);
lookup=griddedInterpolant(fi/object.SampleRate,Pi,'linear');

area=trapz(fi,Pi);
profile=@(fn) lookup(fn)/area;
setNoise(object,RMS,profile);
object.Noise.Source='estimate';

% manage output
if option.Plot
    plot(object,'noise');
end

end