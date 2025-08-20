% write Write to database file
%
% This method writes a structure array to the database file.  
%    >> write(object,data);
% All existing information in this file is overwritten!  To preserve
% existing database records, use the "add" method.
%
% See also SimpleDatabase, add
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function write(object,data)

% verify data
assert(isstruct(data),'ERROR: invalid data type');
Nrecords=numel(data);
name=fields(data);

Nfields=numel(name);
width=max(cellfun(@numel,name));
format=sprintf('%%%ds: ',width);
label=cell(Nfields,1);
for n=1:Nfields
    label{n}=sprintf(format,name{n});
end

% open file and write data
fid=fopen(object.Filename,'w');
assert(fid>2,'ERROR: unable to write database file');

[~,shortname,ext]=fileparts(object.Filename);
fprintf(fid,'# SimpleDatabase file: %s\n',[shortname ext]);
fprintf(fid,'# File updated : %s\n',datestr(now));
fprintf(fid,'# Number of records: %d\n',Nrecords);
fprintf(fid,'# Number of fields: %d\n',Nfields);
for n=1:Nfields
    fprintf(fid,'#\t %s ',label{n});
    temp=data(1).(name{n});
    if ischar(temp)
        fprintf(fid,'character');
    elseif islogical(temp)
        fprintf(fid,'logical');
    elseif isnumeric(temp)
        fprintf(fid,'numeric');
    else
        error('ERROR: unsupported data type detected');
    end
    fprintf(fid,'\n');
end
fprintf(fid,'\n');

for m=1:Nrecords
    % calculate widths...
    for n=1:Nfields        
        temp=data(m).(name{n});
        if isnumeric(temp)
            format=object.NumericFormat;
        elseif islogical(temp)
            format='%d ';
        elseif ischar(temp)
            format='%s';
        else
            error('ERROR: invalid value type');
        end
        temp=strtrim(sprintf(format,temp));
        fprintf(fid,'%s%s\n',label{n},temp);
    end
    if m<Nrecords
        fprintf(fid,'\n');
    end
end

% close file
fclose(fid);

end