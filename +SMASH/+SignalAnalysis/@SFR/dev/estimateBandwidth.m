% estimateBandwidth Estimate measurement bandwidth
%
% This method analyzes the noise spectrum shape, determining the frequency
% below which most of the power resides.  This estimate is stored in the
% Bandwidth property.
%    estimateBandwidth(object);
%
% The behavior of this method is controlled with optional name/value pairs.
%    estimateBandwidth(object,name,value,...);
% Valid options include:
%    -'Threshold', which sets the power fraction used in bandwidth
%    estimation (default is 0.95).  This value can be any number between 0
%    and 1, though it should usually be > 0.90.
%    -'Plot' which controls automatic plot generation.  The value can be
%    'on' (default) or 'off'.
%
% See also SFR, estimateAmplitude, estimateNoise, setBandwidth
%
function estimateBandwidth(object,varargin)

% manage object arrays
if numel(object) > 1
    for n=1:numel(object)
        estimateBandwidth(object(n),varargin{:});
    end
    return
end

% manage input
option=struct('Threshold',0.95,'Plot','on');
try
    option=SMASH.Developer.options2struct(option,varargin{:});
catch ME
    throwAsCaller(ME);
end

value=option.Threshold;
assert(testNumber(value) && (value > 0) && (value < 1),...
    'ERROR: area threshold must be a number between 0 and 1');
if value <= 0.90
    warning('Area threshold should *usually* be > 0.9');
end

if strcmpi(option.Plot,'on')
    option.Plot=true;
elseif strcmpi(option.Plot,'off')
    option.Plot=false;
else
   error('ERROR: plot option must be ''on'' or ''off''');
end

% perform estimate
fn=linspace(0,0.5,1000);
z=object.Noise.ShapeFcn(fn);
z=cumtrapz(fn,z);
z=z/z(end);

index=find(z < option.Threshold,1,'last');
object.Bandwidth=fn(index)*object.SampleRate;

if option.Plot
    plot(object,'bandwidth');
end

end