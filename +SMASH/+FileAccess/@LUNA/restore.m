function object=restore(data)

object=packtools.call('LUNA','-empty');

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        try
        object.(name{n})=data.(name{n});
        catch
        end
    end
end

end