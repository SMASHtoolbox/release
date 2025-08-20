function h=fancyline(varargin)

h=line(varargin{:});
local=get(h,'UserData');

hm=uicontextmenu;
uimenu(hm,'Label',local.Label,'Enable','off');
uimenu(hm,'Label','Set color','Callback',{@linecolor,h},...
    'Separator','on');
set(h,'UIContextMenu',hm);

end

function linecolor(src,eventdata,target)

color=get(target,'Color');
color=uisetcolor(color);
set(target,'Color',color);

local=get(target,'UserData');
fig=findall(0,'Type','figure','Tag','PointVISAR');
data=get(fig,'UserData');
data{local.Record}.LineColor=color;
set(fig,'UserData',data);
%PointVISARGUI(data);

end