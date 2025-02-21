function insert_structure(archive,setname,data,deflate)

file=archive.ArchiveFile;

for m=1:numel(data)
    name=fieldnames(data(m));
    for k=1:numel(name)
        value=data(m).(name{k});
        local=[setname '/' sprintf('element %d',m) '/' name{k}];
        if isnumeric(value)
            insert_numeric(archive,local,value,deflate);
        elseif islogical(value)
            insert_logical(archive,local,value,deflate);
        elseif ischar(value)
            insert_character(archive,local,value,deflate);
        elseif isa(value,'function_handle')
            insert_function(archive,local,value,deflate);
        elseif isstruct(value)
            insert_structure(archive,local,value,deflate);
        elseif iscell(value)
            insert_cell(archive,local,value,deflate);
        elseif isobject(value)
            ObjectClass=class(value);
            value=object2structure(value);
            insert_structure(archive,local,value,deflate);
            h5writeatt(archive.ArchiveFile,local,'Class',ObjectClass);
            h5writeatt(archive.ArchiveFile,local,'RecordType','object');
        end
    end
    h5writeatt(file,setname,'RecordType','structure');
    h5writeatt(file,setname,'RecordSize',size(data));
    h5writeatt(file,setname,'Empty','no');    
    h5writeatt(file,setname,'Fields',sprintf('%s ',name{:}));    
end

end