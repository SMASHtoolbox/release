function insert_object(archive,datasetname,source,deflate)

% convert objects to structures
ObjectClass=class(source);
if strcmpi(ObjectClass,'string')
    data.String=convertStringsToChars(source);
elseif strcmpi(ObjectClass,'table')
    data.Properties=source.Properties;
    name=source.Properties.VariableNames;    
    for k=1:numel(name)
        data.Variable.(name{k})=source.(name{k});        
    end
elseif isscalar(source)
    data=object2structure(source);
else
    data=cell(size(source));
    for n=1:numel(source)
        data{n}=source(n);
    end
end

if isstruct(data)
    insert_structure(archive,datasetname,data,deflate);
    h5writeatt(archive.ArchiveFile,['/' datasetname],'RecordType','object');
elseif iscell(data)
    insert_cell(archive,datasetname,data,deflate);
    h5writeatt(archive.ArchiveFile,['/' datasetname],'RecordType','objects');
else
    error('There was a problem inserting %s',datasetname);
end
h5writeatt(archive.ArchiveFile,['/' datasetname],'Class',ObjectClass);

end