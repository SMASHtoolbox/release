% setWindow Set digital window
%
% This method sets the digital window used in frequency analysis. Windows
% can be specified by name:
%    setWindow(object,name,param); "param" is optional
% or with a function handle.
%    setWindow(object,@(u) myfunc(u));
% Refer to the generateWindow method for specific definitions.
%
% See also SFR, generateWindow, setTimeScale
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
try
    window=object.generateWindow(varargin{:});
catch ME
    throwAsCaller(ME);
end

% store window and update rise time
object.Window=window;
setTimeScale(object);

end