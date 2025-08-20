function StartOver(varargin)

message{1}='Restart PointVISAR program?';
message{2}='All data and settings will be cleared';
answer=questdlg(message,'Restart program?','No');
if strcmpi(answer,'yes')
    fig=findall(0,'Type','figure');
    for n=1:numel(fig)
        tag=get(fig(n),'Tag');
        if strncmp(tag,'PointVISAR',6)
            delete(fig(n));
        end
    end
    PointVISAR
else
    return
end