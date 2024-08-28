% setNoise Set noise content
%
% This method sets the signal's noise content.
%    setNoise(object,RMS,profile);
% The input "RMS" defines the root mean square for noise content in the
% time domain.  The input "profile" defines the noise profile spectrum
% through a function handle.  That function must accept an array of
% normalized frequecies (0 to 0.5) and return an array of the same size.
% Profile functions are automatically scaled to have unity area.
%
% Calling this method without noise information:
%    setNoise(object);
% invokes the default state, where noise assumed to be 10% of the total
% power, distributed uniformly up to half the Nyquist limit (25% sample
% rate).  Empty braces can be used to maintain one setting while changing
% the other.
%    setNoise(object,[],profile); % change profile, leaving RMS as is
%    setNoise(object,RMS,[]); % change RMS, leaving profile as is
%
% Noise content can be transferred from another SFR object.
%    setNoise(object,source);
% Ideally, the input "source" is based on a pure noise measurement.
%
% See also SFR, estimateNoise, plot
%
function setNoise(object,varargin)

% manage object arrays
if numel(object) > 1
    for n=1:numel(object)
        setNoise(object(n),varargin{:});
    end
    return
end

% default state
if nargin == 1
    RMS=sqrt(2)*std(object.Signal)/10;
    ProfileFcn=@BasicNoise;
    setNoise(object,RMS,ProfileFcn);    
    object.Noise.Source='default';
    return
end
    function out=BasicNoise(fn) % normalized to sample rate
        out=zeros(size(fn));
        bandwidth=0.25;
        k=(fn <= bandwidth);
        out(k)=1;
    end

% manage input
flag=false([1 2]);
if isobject(varargin{1})
    source=varargin{1};
    assert(strcmp(class(object),class(source)),...
        'ERROR: invalid source object');
    object.Noise=source.Noise;
    return
elseif isempty(varargin{1})
    RMS=object.Noise.RMS;
else
    RMS=varargin{1};
    assert(testNumber(RMS) && (RMS > 0),...
        'ERROR: RMS noise must be a number > 0');
    flag(1)=true;
end

if (nargin < 3) || isempty(varargin{2})
    ProfileFcn=object.Noise.ShapeFcn;
else
    ProfileFcn=varargin{2};
    assert(isa(ProfileFcn,'function_handle'),...
        'ERROR: shape must be a function handle');
    fn=linspace(0,+0.5,100);
    try
        P=ProfileFcn(fn);
        assert(numel(P) == numel(fn));
    catch
        error('ERROR: shape function does not work correctly');
    end
    flag(2)=true;
end

% store results
data.RMS=RMS;
area=integral(ProfileFcn,0,0.5);
data.ShapeFcn=@(fn) ProfileFcn(fn)/area;
if all(flag)
    data.Source='set';
elseif flag(1)
    data.Source='setRMS';
elseif flag(2)
    data.Source='setShape';
end
object.Noise=data;

end