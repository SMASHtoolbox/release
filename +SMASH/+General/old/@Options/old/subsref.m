function value=subsref(object,data)

assert(numel(data)==1,'ERROR: invalid option name');
assert(strcmp(data.type,'.'),'ERROR: invalid option name');
index=findName(object.Name,data.subs);
assert(~isempty(index),'ERROR: invalid name');
value=object.Value{index};


end