function data=extract_character(archive,setname)

file=archive.ArchiveFile;
empty=readAttribute(file,setname,'Empty');
if strcmp(empty,'yes')
    empty=true;
else
    empty=false;
end

if empty
    data='';
else
    data=h5read(file,setname);
    data=char(data);
end

end