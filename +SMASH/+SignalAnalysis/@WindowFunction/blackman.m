% blackman Generate Blackman window
%
% This *static* method generates a Blackman window of specified size.
%    y=WindowFunction.blackman(N); % integer "N" (default value is 101)
%    y=WindowFunction.blackman(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.Blackman(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.blackman(...);
% plots the window in a new figure.
%
% See also WindowFunction
%

function varargout=blackman(N)

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
y=0.42+0.5*cos(2*pi*x)+0.08*cos(4*pi*x);

% manage output
if nargout == 0
    figure();
    plot(x,y);
    title('Blackman window');    
else
    varargout{1}=y;
    varargout{2}=x;
end

end