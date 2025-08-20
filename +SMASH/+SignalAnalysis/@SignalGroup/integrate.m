% INTEGRATE Numerically integrate a SignalGroup
%
% This method numerically integrates a SignalGroup object, resulting in a
% new object.
%    >> new=integrate(object);
% Trapezoidal integration on the object's Grid array is used; no input
% parameters are accepted.
%
% See also SignalGroup, differentiate
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=integrate(object)

[x,y]=limit(object);
y=cumtrapz(x,y,1);

object.Grid=x;
object.Data=y;

object=updateHistory(object);

end