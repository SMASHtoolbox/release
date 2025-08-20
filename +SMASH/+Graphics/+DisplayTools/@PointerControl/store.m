% store Store pointer location
%
% This method stores the current pointer location in the History property.
%    store(object);
% Pointer locations can also be stored manually.
%    store(object,[x y]);
% Inputs "x" and "y" should be specified in pixels
%
% See also PointerControl, rewind
% 

%
% created January 17, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function store(object,location)

% manage input
if (nargin < 2) || isempty(location)
    location=getCursorLocation();
else
    assert(isnumeric(location) && (numel(location) == 2),...
        'ERROR: invalid pointer location');
    location=reshape(location,[1 2]);
end

% update history
if isempty(object.History)
    object.History=location;
else
    object.History(end+1,:)=location;
end

end