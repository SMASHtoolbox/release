% psinc Generate power cosine window
%
% This *static* method generates a power cosine window of specified size.
%    y=WindowFunction.psinc(N); % integer "N" (default value is 101) 
%    y=WindowFunction.psinc(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.psinc(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.psinc(...);
% plots the window in a new figure.
%
%
% Window order can be specified by any power >= 1.
%    [..]=WindowFunction.psinc(N,order);
% The default order is 2, also known as the Fejer window; the de la Vallee
% Poussin window is order=4.
%
% See also WindowFunction
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=psinc(N,order)

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
y=SMASH.SignalAnalysis.sinc(2*x,'normalized');
y=y.^(order);

% manage output
if nargout == 0
    figure();
    plot(x,y);
    label=sprintf('psinc window (order = %d)',order);
    title(label);  
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end