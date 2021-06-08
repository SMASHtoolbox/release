function insert_structure(archive,setname,data,deflate)

file=archive.ArchiveFile;

% manage structure arrays
N=numel(data);
if N > 1
    temp=cell(size(data));
    for m=1:N
        temp{m}=data(m);
    end
    insert_cell(archive,setname,temp,deflate);
    h5writeatt(file,setname,'RecordType','structures');
    return
end

% manage individual structures
name=fieldnames(data);
for k=1:numel(name)
    value=data.(name{k});
    local=[setname '/' name{k}];
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
        insert_object(archive,local,value,deflate);
    end
end
h5writeatt(file,setname,'RecordType','structure');

%h5writeatt(file,setname,'RecordSize',size(data));
h5writeatt(file,setname,'Empty','no');
h5writeatt(file,setname,'FieldNames',sprintf('%s ',name{:}));


end