% monpoly Monotonic polynomial
%
% This function calculates a monotonic polynomial at specified locations.
%    y=monpoly(param,x);
% The input "param" defines polynomial coefficients and the input "x"
% defines where the polynomial is evaluated.  The output "y" matches the
% size and shape of input "x".  The first value of y is zero by convention.
%
% Monotonic behavior is enforced by:
%    -Using the polynomial coefficients to define an intermediate slope.
%    -Squaring the intermediate slope so that dydx is never negative.
%    -Integrating the result to produce y(x).
% The result is a never-decreasing function y(x) by default; a third input
% argument:
%    y=monpoly(param,x,'falling');
% inverts the result be never increasing.  The slope function is retured as
% a second output as requested.
%    [y,dydx]=monpoly(...);
%
% See also SMASH.CurveFit, polyval
%

%
% created November 11, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function [y,dydx]=monpoly(param,x,direction)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');

assert(isnumeric(param) && ~isempty(param),...
    'ERROR: invalid parameter input');
param=reshape(param,1,[]);

assert(isnumeric(x) && ~isempty(x) && ismatrix(x),...
    'ERROR: invalid evaluation array');
temp=size(x);
assert((temp(1) == 1) || (temp(2) ==1),'ERROR: evaluation array must be 1D');

if (nargin < 3) || isempty(direction) || strcmpi(direction,'rising')
    falling=false;
elseif strcmpi(direction,'falling')
    falling=true;
else
    error('ERROR: invalid direction');
end

% calculations
param=conv(param,param); 
if nargout >= 2
    dydx=polyval(param,x);
end

param=polyint(param);
y=polyval(param,x)-polyval(param,min(x));
if falling
    y=-y;
end

end