function StartOver(src,varargin)

% prompt user
message{1}='Are you sure you want to restart?';
message{2}='All unsaved data will be lost';
button=questdlg(message,'Restart THRIVE?','No');

if strcmpi(button,'yes') 
    data=get(src,'UserData');
    % close all figures
    basetag='THRIVE_';
    Nbase=numel(basetag);
    fig=allchild(0);
    for ii=1:numel(fig)
        tag=get(fig(ii),'Tag');
        if strncmp(tag,basetag,Nbase)
            delete(fig(ii));
        end
    end
    feval(data.fhandle); % relaunch program
else
    figure(gcbf); % return to callback figure
end