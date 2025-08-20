% bspline Generate B-spline window
%
% This *static* method generates a B-spline window of specified size.
%    y=WindowFunction.bspline(N); % integer "N" (default value is 101) 
%    y=WindowFunction.bspline(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.bspline(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.bspline(...);
% plots the window in a new figure.
%
% Window order can be specified by an integer from 3 (default) to 5.
%    [..]=WindowFunction.bspline(N,order);
% Some B-spine windows are associated with other names:

%    -The Parzen window is identical to order=4;
%
% See also WindowFunction
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=bspline(N,order)

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
    order=3;
else
    assert(isnumeric(order) && isscalar(order),'ERROR: invalid order');
    valid=3:5;
    assert(any(order == valid),'ERROR: order must be an integer from 3 to 5');
end

% generate window
x=linspace(-0.5,+0.5,N);
y=ones(size(x));
switch order  
    case 3 
        k=abs(x) <= (1/6);
        y(k)=9/8*(2-24*abs(x(k)).^2);
        k=~k;
        y(k)=(9/8)*(3-12*abs(x(k))+12*abs(x(k)).^2);
        y=y*(4/9);
    case 4 % parzen
        k=abs(x) < 0.25;
        xk=abs(x(k));
        y(k)=(8/3)*(1-24*xk.^2+48*xk.^3);
        k=~k;
        xk=abs(x(k));
        y(k)=(8/3)*(2-12*xk+24*xk.^2-16*xk.^3);
        y=y*(3/8);
    case 5
        k=abs(x) <= (1/10);
        xk=abs(x(k));
        y(k)=(25/384)*(46-1200*xk.^2+12000*xk.^4);
        k=(abs(x) > (1/10)) & (abs(x) <= (3/10));
        xk=abs(x(k));
        y(k)=(25/384)*(44+80*xk-2400*xk.^2+8000*xk.^3-8000*xk.^4);
        k=(abs(x) > (3/10));
        xk=abs(x(k));
        y(k)=(25/384)*(125-1000*xk+3000*xk.^2-4000*xk.^3+2000*xk.^4);
        y=y*(384/1150);
end

% manage output
if nargout == 0
    figure();
    plot(x,y);
    label=sprintf('B-spline window (order = %d)',order);
    title(label);  
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end