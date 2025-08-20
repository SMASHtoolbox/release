function object=extract_object(archive,setname)

temp=extract_structure(archive,setname);
try
    ObjectClass=readAttribute(archive.ArchiveFile,setname,'Class'); % documented standard
catch
    ObjectClass=readAttribute(archive.ArchiveFile,setname,'ClassName'); % undocumented alternative
end

switch ObjectClass       
    case 'string'
        object=convertCharsToStrings(temp.String);
    case 'table'
        name=fieldnames(temp.Variable);
        arg=cell(1,numel(name));
        for k=1:numel(name)
            arg{k}=temp.Variable.(name{k});
        end
        object=table(arg{:});
        object.Properties=temp.Properties;
    otherwise
        object=structure2object(temp,ObjectClass);
end

end