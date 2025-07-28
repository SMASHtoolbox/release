% flattop Generate flat-top window
%
% This *static* method generates a flat-top window of specified size.
%    y=WindowFunction.flattop(N); % integer "N" (default value is 101) 
%    y=WindowFunction.flattop(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.flattop(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.flattop(...);
% plots the window in a new figure.
%
% Window order can be specified as 3 or 5 (default).
%    [..]=WindowFunction.flattop(N,order);
%
% See also WindowFunction
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=flattop(N,order)

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
    order=5;
else
    assert(isnumeric(order) && isscalar(order),'ERROR: invalid order');
    valid=[3 5];
    assert(any(order == valid),'ERROR: order must be 3 or 5');
end

% generate window
x=linspace(-0.5,+0.5,N);
switch order  
    case 3
        a=[0.2811 0.5209 0.1980];
    case 5
        a=[0.21557895 0.41663158 0.277263158 0.083578947 0.006947368];
end

y=zeros(size(x));
for k=0:(order-1)
    y=y+a(k+1)*cos(2*pi*k*x);
end
y=y/sum(a);

% manage output
if nargout == 0
    figure();
    plot(x,y);
    label=sprintf('Flat-top window (order = %d)',order);
    title(label);  
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end