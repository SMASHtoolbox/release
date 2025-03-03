function varargout=checkStatus(archive)

status=struct;

info=h5info(archive.ArchiveFile,'/');
attributes=info.Attributes;
for n=1:numel(attributes)
    name=attributes(n).Name;   
    value=attributes(n).Value;
    if iscell(value)
        if numel(value) > 1
            warning(...
                'WARNING: multiple attribute values detected.  Only the first value will be kept.');
        end
        value=value{1};
    end
    status.(name)=value;
end
status=orderfields(status);

if nargout==0
    disp(status);
else
    varargout{1}=status;
end

end