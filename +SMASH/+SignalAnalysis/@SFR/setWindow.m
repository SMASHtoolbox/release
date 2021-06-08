% setWindow Set digital window
%
% This method sets the digital window used in frequency analysis.  Windows
% can be specified by name with an optional numeric parameter.
%    setWindow(object,name); % "name" must be character array
%    setWindow(object,name,parameter);
% Supported window names include include:
%    -'boxcar', no parameters.
%    -'blackman', no parameters.
%    -'bspline', 1 parameter (order=3, 4, or 5).  Default order is 3.
%    -'connes', no parameters.
%    -'flattop', 1 parmeter (order=3 or 5).  Default order is 3.
%    -'hamming', no parameters.
%    -'hann', no parameters.
%    -'kaiser', 1 parameter (beta >= 1).  Default beta is 16.
%    -'pcosine', 1 parameter (order >= 1).  Default order is 2.
%    -'psinc', 1 parameter (order >= 1).  Default order is 2.
%    -'singla' , 1 parameter (order=1 or 2).  Default order is 1
%    -'triangle', 1 parameter (order >= 1).  Default order is 1
%    -'tukey', 1 parameter (0 < beta < 1).  Default beta is 0.5.
%    -'vorbis', no parameters.
%
% Custom window functions can also be specified.
%    setWindow(object,@(time) myfunc(time));
% The function "myfunc" must accept an input array and return an array of
% the same size.  Note that normalized times from -0.5 to +0.5 are passed
% to the window function.
%
% See also SFR, setParameter
%
function setWindow(object,varargin)

% manage object arrays
if numel(object) > 1
    for n=1:numel(object)
        setWindow(object(n),varargin{:});
    end
    return
end

% manage input
assert(nargin > 1,'ERROR: insufficient input');

window=struct('Name','','Function',[],'Scaling',[]);
if (nargin == 2) && isa(varargin{1},'function_handle')
    window.Name='custom';
    window.Function=varargin{1};
elseif ischar(varargin{1})
    try
        window=object.generateWindow(varargin{:});
    catch ME
        throwAsCaller(ME);
    end  
else
    error('ERROR: invalid window ');
end

% time characterization
try
    area0=integral(window.Function,-0.5,+0.5);
catch
    error('ERROR: window must accept normalized times from -0.5 to +0.5');
end
area2=integral(@(u) u.^2.*window.Function(u),-0.5,+0.5);
window.Scaling=sqrt(area2/area0);
% 
% window.SquareIntegral=integral(@(u) window.Function(u).^2,-0.5,+0.5);

object.Window=window;

% invoke rise time setter
if isnan(object.RiseTime) ...
        || (object.RiseTime < object.MinimumRise) ...
        || (object.RiseTime > object.MaximumRise)
    object.RiseTime=[];
end

% update noise spectrum
if isempty(object.Noise)
    setNoise(object);
else
    setNoise(object,object.Noise.RMS,object.Noise.ShapeFcn);
end

end