function insert_cell(archive,datasetname,data,deflate)

file=archive.ArchiveFile;
if isempty(data)
    data={[]};
    empty=true;
else
    empty=false;
end

for k=1:numel(data)
    local=[datasetname '/' sprintf('element %d',k)];
    value=data{k};
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
h5writeatt(file,datasetname,'RecordType','cell');
h5writeatt(file,datasetname,'RecordSize',size(data));

if empty
    h5writeatt(file,datasetname,'Empty','yes');
else
    h5writeatt(file,datasetname,'Empty','no');
end

end