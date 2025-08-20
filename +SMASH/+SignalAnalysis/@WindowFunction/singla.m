% singla Generate Singla-Singh window
%
% This *static* method generates a Singla-Singh window of specified size.
%    y=WindowFunction.singla(N); % integer "N" (default value is 101) 
%    y=WindowFunction.singla(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.singla(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.singla(...);
% plots the window in a new figure.
%
% Window order can be specified by an integer from 1 (default) to 2.
%    [..]=WindowFunction.singla(N,order);
%
% See also WindowFunction
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=singla(N,order)

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
    order=1;
else
    assert(isnumeric(order) && isscalar(order),'ERROR: invalid order');
    valid=1:2;
    assert(any(order == valid),'ERROR: order must be an integer from 1:2');
end

% generate window
x=linspace(-0.5,+0.5,N);
t=2*x;
y=ones(size(x));
switch order  
    case 1
        y=1-t.^2.*(3-2*abs(t));
    case 2
        y=1-abs(t).^3.*(10-15*abs(t)+6*t.^2);        
end

% manage output
if nargout == 0
    figure();
    plot(x,y);
    label=sprintf('Singla-Singh window (order = %d)',order);
    title(label);  
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end