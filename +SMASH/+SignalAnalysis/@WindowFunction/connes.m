% connes Generate Connes window
%
% This *static* method generates a Connes window of specified size.
%    y=WindowFunction.connes(N); % integer "N" (default value is 101) 
%    y=WindowFunction.connes(array); % determine N from "array" size.
% Requesting a second output:
%    [y,x]=WindowFunction.connes(...);
% returns an array of locations from -0.5 to 0.5 where the window is
% defined.  Calling this method with no output:
%    WindowFunction.connes(...);
% plots the window in a new figure.
%
% See also WindowFunction
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=connes(N)

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

% generate window
x=linspace(-0.5,+0.5,N);
y=(1-4*x.^2).^2;

% manage output
if nargout == 0
    figure();
    plot(x,y);
    label=sprintf('Connes window');
    title(label);  
    ylim([-0.1 1.1]);
else
    varargout{1}=y;
    varargout{2}=x;
end

end