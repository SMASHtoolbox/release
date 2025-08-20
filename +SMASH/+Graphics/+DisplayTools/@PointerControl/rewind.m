% rewind Return pointer to stored location
%
% This method returns the pointer to the last stored location.
%    rewind(object);
% Each method call removes a stored location from the History property.
% When no stored locations remain, this method has no effect.
%
% See also PointerControl, store

%
% created January 17, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function rewind(object)

if isempty(object.History)
    return
end

object.Location=object.History(end,:);
object.History=object.History(1:end-1,:);

end