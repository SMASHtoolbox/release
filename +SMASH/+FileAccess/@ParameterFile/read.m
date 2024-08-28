% read Read parameter file
%
% This method reads a parameter file into a structure.
%    data=read(object);
% The output "data" has structure fields for each parameter set defined in
% the file; repeated set names are stored as structure arrays.
%
% See also ParameterFile, write
%

%
% created May 10, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function data=read(object)

start=pwd;
cd(object.PathName);
fid=fopen(object.FileName,'r');
cd(start);
CU=onCleanup(@() fclose(fid));

data=struct();
LineNumber=0;
inside=false; % configuration block flag
entry='';
while ~feof(fid)
    %
    temp=strtrim(fgetl(fid));
    LineNumber=LineNumber+1;    
    if isempty(temp) || (temp(1) == '%') % drop empty lines and comments
        entry='';
        continue       
    elseif (numel(temp) >= 3) && strcmp(temp(end-2:end),'...') % 
        entry=sprintf('%s %s',entry,temp(1:end-3));
        continue
    else       
        entry=sprintf('%s %s',entry,temp);
    end    
    entry=strtrim(entry);
    %
    if (numel(entry) >= 7) && strncmp(entry,'begin{',6)
        stop=strfind(entry,'}');
        assert(~isempty(stop),...
            'ERROR: invalid begin statement on line %d',LineNumber);        
        GroupName=entry(7:(stop(1)-1));
        assert(isvarname(GroupName),...
            'ERROR: invalid group name on line %d',LineNumber');
        inside=true;
        if isfield(data,GroupName)
            temp=data.(GroupName);
            temp(end+1)=temp(end); %#ok<AGROW>
            name=fieldnames(temp);
            for n=1:numel(name)
                temp(end).(name{n})=[];
            end
            data.(GroupName)=temp;
        else
            data.(GroupName)=struct();
        end
    elseif (numel(entry) >= 3) && strcmp(entry(1:3),'end')
        inside=false;
    else
        try
            assert(inside);
            index=strfind(entry,'=');
            assert(~isempty(index),'');
            index=index(1);
            name=strtrim(entry(1:(index-1)));
            assert(isvarname(name),'');           
            value=entry((index+1):end);
        catch
            error('ERROR: invalid statement on line %d',LineNumber);
        end
        temp=data.(GroupName);
        temp(end).(name)=eval(value);
        data.(GroupName)=temp;
    end
    entry='';
end    

end