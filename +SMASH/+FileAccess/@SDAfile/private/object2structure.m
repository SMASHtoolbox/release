function data=object2structure(object)

data=struct();
list=metaclass(object);
list=list.PropertyList;
for n=1:numel(list)
    name=list(n).Name;
    try %#ok<TRYNC>
        data.(name)=object.(name);
    end
end

end