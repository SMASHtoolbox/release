% pcosine Generate power cosine window
%
% This *static* method generates a power cosine window of specified size.
%    y=WindowFunction.pcosine(N); % integer "N" (default value is 101) 
%    y=WindowFunction.pcosine(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.pcosine(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.pcosine(...);
% plots the window in a new figure.
%
%
% Window order can be specified by any power >= 1.
%    [..]=WindowFunction.pcosine(N,order);
% The default order is 2, forcing the window and its derivative to zero at
% the boundaries.
%
% See also WindowFunction
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=pcosine(N,order)

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

if (nargin < 2) || isempty(order)
    order=2;
else
    assert(isnumeric(order) && isscalar(order) && (order >= 1),...
        'ERROR: order must be greater than or equal to 1');
end

% generate window
x=linspace(-0.5,+0.5,N);
y=cos(pi*x).^order;

% manage output
if nargout == 0
    figure();
    plot(x,y);
    label=sprintf('pcosine window (order = %d)',order);
    title(label);  
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end