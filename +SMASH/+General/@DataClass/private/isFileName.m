function result=isFileName(object,name)

result=true;
if ~ischar(name)
    result=false;
    return
end

if isprop(object,'ReservedNames')
    list=object.ReservedNames;
    for k=1:numel(list)
        if strcmp(name,list{k})
            result=false;
            break
        end
    end
end

end