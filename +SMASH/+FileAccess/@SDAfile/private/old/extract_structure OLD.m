function data=extract_structure(archive,setname)

file=archive.ArchiveFile;

% extract field names
name=cell(0);
temp=h5readatt(file,setname,'Fields');
while ~isempty(temp)
    [new,~,~,next]=sscanf(temp,'%s',1);
    if ~isempty(new)
        name{end+1}=new; %#ok<AGROW>
    end
    temp=temp(next:end);
end

record_size=h5readatt(file,setname,'RecordSize');
record_size=transpose(record_size(:));
data=struct();
data=repmat(data,record_size);
N=prod(record_size);
for m=1:N
    for k=1:numel(name)
        local=[setname '/' sprintf('element %d',m) '/' name{k}];
        switch h5readatt(file,local,'RecordType')
            case 'numeric'
                data(m).(name{k})=extract_numeric(archive,local);
            case 'logical'
                data(m).(name{k})=extract_logical(archive,local);
            case 'character'
                data(m).(name{k})=extract_character(archive,local);
            case 'function'
                data(m).(name{k})=extract_function(archive,local);
            case 'structure'
                data(m).(name{k})=extract_structure(archive,local);
            case 'cell'
                data(m).(name{k})=extract_cell(archive,local);
            case 'object'
                temp=extract_structure(archive,local);
                ObjectClass=h5readatt(archive.ArchiveFile,local,'Class');
                data(m).(name{k})=structure2object(temp,ObjectClass);
            otherwise
                error('ERROR: invalid record type');
        end
    end
end

end