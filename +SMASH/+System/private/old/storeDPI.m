function storeDPI(DPI)

% locate log file
pathname=fileparts(mfilename('fullpath'));
filename=fullfile(pathname,'DPI.log');
if ~exist(filename,'file') %  create log file if it doesn't already exist
    fid=fopen(filename,'w');
    fprintf(fid,...
        'Screen calibration settings [host DPI width height date time]\n');
    fclose(fid);
end

% search log file for host ID
ID=SMASH.System.hostID();
fid=fopen(filename,'r');
match=false;

header=fgets(fid);
record=sprintf('%s',header);

while ~feof(fid)
    temp=fgetl(fid);
    entry=sscanf(temp,'%s',1);
    if strcmp(entry,ID)
        primary=get(0,'ScreenSize');
        temp=sprintf('%s %.3f %d %d %s\n',...
            ID,DPI,primary(1),primary(2),datestr(now));
        match=true;
    end
    temp=strtrim(temp);
    record=sprintf('%s%s\n',record,temp);
end
fclose(fid);

% add new log file entry
fid=fopen(filename,'w');
fprintf(fid,'%s',record);
if ~match
    fprintf(fid,'%s %.3f %s\n',ID,DPI,datestr(now));
end
fclose(fid);

end