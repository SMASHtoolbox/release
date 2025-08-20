% INTEGRATE Numerically integrate a Signal object
%
% This method numerically integrates a Signal object, resulting in a new
% object.
%    >> new=integrate(object);
% Trapezoidal integration on the object's Grid array is used; no input
% parameters are accepted.
%
% See also Signal, differentiate
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=integrate(object)

[x,y]=limit(object);
y=cumtrapz(x,y);

object.Grid=x;
object.Data=y;
object=limit(object,'all');

object=updateHistory(object);

end