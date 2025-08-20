function StartOver(src,varargin)

message{1}='Restart SIRHEN program?';
message{2}='All data and settings will be cleared';
answer=questdlg(message,'Restart program?','No');
if strcmpi(answer,'yes')
    fig=findall(0,'Type','figure');
    for n=1:numel(fig)
        tag=get(fig(n),'Tag');
        if strncmp(tag,'SIRHEN',6)
            delete(fig(n));
        end
    end
    SIRHEN
else
    return
end