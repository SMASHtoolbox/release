% tukey Generate Tukey window
%
% This *static* method generates a Tukey window of specified size.
%    y=WindowFunction.tukey(N); % integer "N" (default value is 101) 
%    y=WindowFunction.tukey(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.tukey(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.tukey(...);
% plots the window in a new figure.
%
% The transition point can be specifed from 0.10 to 0.90.
%    [..]=WindowFunction.tukey(N,alpha);
%
% See also WindowFunction
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=tukey(N,alpha)

% manage input
if (nargin == 0) || isempty(N)
   N=101;
elseif SMASH.General.testNumber(N,'integer','positive')
    % keep going
else
    assert(isnumeric(N),'ERROR: invalid evaluation grid');
    N=numel(N);
end
assert(N >= 5,'ERROR: minimum number of points is 5');

if (nargin < 2) || isempty(alpha)
    alpha=0.5;
else
    assert(isnumeric(alpha) && isscalar(alpha) && (alpha > 0) && (alpha < 1),...
        'ERROR: alpha must be greater than 0 and less than 1');
end

% generate window
x=linspace(-0.5,+0.5,N);
y=ones(size(x));
x0=alpha/2;
k=(abs(x) >= x0);
y(k)=(1+cos(pi*(abs(x(k))-x0)/(0.5-x0)))/2;

% manage output
if nargout == 0
    figure();
    plot(x,y);
    label=sprintf('Tukey window (alpha = %g)',alpha);
    title(label);  
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end