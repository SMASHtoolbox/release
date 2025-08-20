function data=extract_function(archive,setname)

% transcribe archive data to a MAT file
data=h5read(archive.ArchiveFile,setname);
tempfile=sprintf('temporary_%.9f.mat',now);
fid=fopen(tempfile,'w');
fwrite(fid,data,'uint8');
fclose(fid);

% load handle from MAT file
load(tempfile,'data','-mat');
delete(tempfile);

end
