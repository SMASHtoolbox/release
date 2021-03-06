function insert_character(archive,setname,data,deflate)

% handle empty arrays
file=archive.ArchiveFile;
empty=false;
if isempty(data);
    empty=true;
    data=' ';
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
data=uint8(data);
if any(data>127)
    warning('Non-ASCII character records are not supported by SDA');
end
h5write(file,setname,data,start,count);
h5writeatt(file,setname,'RecordType','character');

if empty
    h5writeatt(file,setname,'Empty','yes');
else
    h5writeatt(file,setname,'Empty','no');
end