function object=convert(object,data)

ObjectClass=class(object);
DataClass=class(data);

if isa(data,ObjectClass) % convert from subclass to superclass
    name=properties(object);
    for k=1:numel(name)
        object.(name{k})=data.(name{k});
    end
    message={};
    message{end+1}=sprintf('Converting from %s to %s',DataClass,ObjectClass);
    message{end+1}='Information may be lost';
    warning('SMASH:ClassConversion','%s\n',message{:});
elseif isa(object,DataClass) % convert from superclass to subclass
    error('ERROR: superclass to subclass conversion not supported');
end


end