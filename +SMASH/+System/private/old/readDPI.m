function varargout=readDPI()

% locate log file
pathname=fileparts(mfilename('fullpath'));
filename=fullfile(pathname,'DPI.log');
if ~exist(filename,'file') %  create log file, if it doesn't already exist
    fid=fopen(filename,'w');
    fprintf(fid,'Screen calibration settings\n');
    fclose(fid);
end

% read log file
fid=fopen(filename,'r');
header=fgetl(fid);
table=[];
k=0;
while ~feof(fid)
   temp=fgetl(fid);
   
end

end