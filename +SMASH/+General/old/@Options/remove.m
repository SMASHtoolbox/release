% remove Remove option from an Options object
%
% This method removes an existing option from an Options object.
%     >> object=remove(object,name);
%
% See also Options, add
%

%
% created November 16, 2014 by Daniel Dolan (November 16, 2014)
%
function object=remove(object,name)

% handle input
assert(nargin==2,'ERROR: invalid input');
if strcmp(name,'-all')
    while numel(object.Name)>0
        object=remove(object,object.Name{1});
    end
    return
end

% remove name if it exists
index=findName(object.Name,name);
assert(~isempty(index),'ERROR: option not found');

keep=[1:(index-1) (index+1):numel(object.Name)];
object.Name=object.Name(keep);
object.Value=object.Value(keep);
object.Allowed=object.Allowed(keep);
object.Description=object.Description(keep);
object.DescriptionLock=object.DescriptionLock(keep);

end