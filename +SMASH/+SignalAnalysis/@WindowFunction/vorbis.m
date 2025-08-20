% vorbis Generate Vorbis window
%
% This *static* method generates a Vorbis window of specified size.
%    y=WindowFunction.vorbis(N); % integer "N" (default value is 101)
%    y=WindowFunction.vorbis(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.vorbis(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.vorbis(...);
% plots the window in a new figure.
%
% See also WindowFunction
%

function varargout=vorbis(N)

% manage input
if (nargin == 0) || isempty(N)
   N=101;
elseif SMASH.General.testNumber(N,'integer')
    % keep going
else
    assert(isnumeric(N),'ERROR: invalid evaluation grid');
    N=numel(N);
end
assert(N >= 5,'ERROR: minimum number of points is 5');

% generate window
x=linspace(-0.5,+0.5,N);
y=sin(pi/2*cos(pi*x).^2);

% manage output
if nargout == 0
    figure();
    plot(x,y);
    title('Vorbis window');    
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end