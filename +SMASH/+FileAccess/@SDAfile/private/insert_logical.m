function insert_logical(archive,setname,data,deflate)

% handle empty arrays
file=archive.ArchiveFile;
empty=false;
if isempty(data);
    empty=true;
    data=nan;
end

% insert data
chunksize=size(data);
datatype='uint8';

%datasize=size(data);  
datasize=inf(1,ndims(data));
start=ones(1,ndims(data));
count=size(data);
h5create(file,setname,datasize,...
    'ChunkSize',chunksize,'Deflate',deflate,'DataType',datatype);
h5write(file,setname,uint8(data),start,count);
h5writeatt(file,setname,'RecordType','logical');

if empty
    h5writeatt(file,setname,'Empty','yes');
else
    h5writeatt(file,setname,'Empty','no');
end

%h5writeatt(file,setname,'DataType',datatype);