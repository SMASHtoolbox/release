function insert_function(archive,setname,data,~) % deflate input not used

% generate MAT file representation of function handle
fstring=func2str(data);
%tempfile=sprintf('temporary_%.9f.mat',now);
tempfile=[tempname '.mat'];
save(tempfile,'data','-v7.3');

fid=fopen(tempfile,'r');
data=fread(fid,[1 inf],'uint8');
fclose(fid);
delete(tempfile);

% insert MAT representation into archive
h5create(archive.ArchiveFile,setname,size(data),'Datatype','uint8');
h5write(archive.ArchiveFile,setname,uint8(data));
h5writeatt(archive.ArchiveFile,setname,'RecordType','function');
h5writeatt(archive.ArchiveFile,setname,'Command',fstring);
h5writeatt(archive.ArchiveFile,setname,'Empty','no');

end