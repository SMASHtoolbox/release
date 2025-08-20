% get Reveal existing option value
%
% This method reads the value of an existing option.
%     >> value=get(object,name);
%
% See also Options, add, describe, set
%


%
% created November 17, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function value=get(object,name)

index=findName(object.Name,name);
assert(~isempty(index),'ERROR: invalid name');
value=object.Value{index};

end