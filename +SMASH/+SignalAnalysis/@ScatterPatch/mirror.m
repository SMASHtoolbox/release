% mirror Vertical patch duplication
%
% This method duplicates patches about the horizontal axis.
%    mirror(object,group);
% The input "group" indicates the patch groups to be mirrored; all groups
% are used if this argument is empty or omitted.  Values must be consistent
% with the GroupList property.
% 
% See also ScatterPatch
%
function mirror(object,group)

if nargin < 2
    group=[];
end

if numel(object) > 1
    for n=1:numel(object)
        mirror(object,group)
    end
    return
end

if isempty(group)
    group=object.GroupList;
else
    ERRMSG='ERROR: invalid group number(s)';
    assert(isnumeric(group),ERRMSG)
    for n=1:numel(group)
        assert(any(group(n) == object.GroupList),ERRMSG);
    end
end

% mirror selected groups
data=object.RawData;
new=nan(size(data));
for n=1:numel(group)
    index=(data(:,5) == group(n));
    new(index,:)=data(index,:);
    new(index,2)=-new(index,2);
end
data=[data; new];
object.RawData=data;

end