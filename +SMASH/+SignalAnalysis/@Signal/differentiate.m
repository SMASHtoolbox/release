% DIFFERENTIATE Calculate numerical derivative
%
% This method numerically differentiates a Signal object, resulting in a
% new object.
%    >> new=differentiate(object);
% By default, a centered difference approximation is used to calculate the
% derivative.  Polynomial smoothing (Savitzky-Golay method) of order k can
% be specified over N points as follows.
%    >> new=differentiate(object,[k N]); 
% The number of points should be an odd number equal to or larger than k.
%
% The default derivative level is 1.  Higher derivatives can be requested
% with a third input argument.
%     >> new=differentiate(object,[k N],m); % calculate m-th derivative
% Remember that m cannot exceed k!
% 
% By default, edge derivatives are handled by zero padding.  Edge
% management can be controlled with a fourth input argument.
%     >> new=differentiate(object,[k N],m,edge);
% Three edge options are supported: 'zero', 'nan', and 'extrapolate'.
%
% See also Signal, integrate
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
% updated December 20, 2013 by Daniel Dolan
%    -added support edge support, defaulting to 'extrapolate' instead of
%    'nan'
%
function [object,weight]=differentiate(object,param,level,edge)

% verify uniform grid
object=makeGridUniform(object);

% handle input
if (nargin<2) || isempty(param)
    param=[1 3];
end

if (nargin<3) || isempty(level)
    level=1;
end

if (nargin<4) || isempty(edge)
    %edge='extrapolate';
    edge='zero';
end

% calculate derivative
[x,y]=limit(object);
[dydx,param]=SGderivative(level,param,y,x);

% handle edges
numpoints=param(2);
L=(numpoints-1)/2;
switch lower(edge)
    case 'zero'
        dydx(1:L)=0;
        dydx(end-L+1:end)=0;
    case 'nan'
        % do nothing
    case {'extrap','extrapolate'}
        % left side
        index=1:numpoints;
        index=index+L;
        a=polyfit(x(index),dydx(index),1);
        dydx(1:L)=polyval(a,x(1:L));
        % right side
        index=0:(numpoints-1);
        index=numel(x)-index-L;
        a=polyfit(x(index),dydx(index),1);
        dydx(end-L+1:end)=polyval(a,x(end-L+1:end));
    otherwise
        error('ERROR: invalid edge option');
end

object.Grid=x;
object.Data=dydx;
object=limit(object,'all');

%object=updateHistory(object);
if nargout >= 2
    weight=SGderivative(level,param);
end

end