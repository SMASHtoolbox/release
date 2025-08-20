% 
function restoreDPI()

% locate log file
pathname=fileparts(mfilename('fullpath'));
filename=fullfile(pathname,'DPI.log');
if ~exist(filename,'file')
    error('ERROR: no screen calibration exists for this system');
end

% read log file
ID=mui.tools.hostID;
fid=fopen(filename,'r');
[~]=fgetl(fid); % read header
while ~feof(fid)
   temp=fgetl(fid);
   [entry,~,~,next]=sscanf(temp,'%s',1);
    if strcmp(entry,ID)       
        DPI=sscanf(temp(next:end),'%g',1);
        set(0,'ScreenPixelsPerInch',DPI);
        return
    end
end
error('ERROR: no screen calibration exists for this system');

end