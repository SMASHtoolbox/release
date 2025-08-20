% read edit box callback
function data=ReadEditBox(src,varargin)

entry=get(src,'String');
[data,count,err,next]=sscanf(entry,'%g',1);

if isempty(data) % use stored value for failed read
    data=get(src,'UserData');
    set(src,'String',num2str(data));
else % store new value for successful read
    entry=entry(1:(next-1));
    set(src,'UserData',data,'String',entry);    
end