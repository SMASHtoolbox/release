% WRITE Write file associated with a DIGfile object
%
% Syntax:
%    >> success=write(object,time,signal);
%
%
% This method writes information to the file associated with a Digitizer
% object.
%  
%
% see also Digitizer, probe, read

function write(object,time,signal)

if exist(object.FullName,'file')
    message{1}='Target file already exists.';
    message{2}='Should it be overwritten?';
    choice=questdlg(message,'Overwrite file','Yes','No','No');
    if ~strcmp(choice,'Yes')
        return
    end
end

% write the file
try
    write_nts(signal,time,object.FullName);
    success=true;
catch
    success=false;
end

end