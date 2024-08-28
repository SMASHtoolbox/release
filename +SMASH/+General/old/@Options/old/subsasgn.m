function object=subsasgn(object,data,value)

assert(numel(data)==1,'ERROR: invalid option name');
assert(strcmp(data.type,'.'),'ERROR: invalid option name')
assert(isnumeric(value) | ischar(value),'ERROR: invalid value');

index=findName(object.Name,data.subs);
assert(~isempty(index),'ERROR: invalid option name');
valid=isAllowed(object.Allowed{index},value);
assert(valid,'ERROR: invalid %s value',object.Name{index});
object.Value{index}=value;

end

function flag=isAllowed(list,value)

flag=false;
if isempty(list)
    flag=true;
elseif iscell(list)
    for k=1:numel(list)
        if isnumeric(list{k}) && all(list{k}==value)
            flag=true;
            break
        elseif ischar(list{k}) && strcmp(list{k},value)
            flag=true;
            break
        end
    end
elseif isa(list,'function_handle')
    flag=feval(list,value);
end

end