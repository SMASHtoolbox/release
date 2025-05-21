function NudgePopupMenus(fig)

h=findobj(fig,'Type','uicontrol','Style','popup');
for k=1:numel(h)
    pos=get(h(k),'Position');
    extent=get(h(k),'Extent');
    pos(2)=pos(2)-extent(4)/4;
    set(h(k),'Position',pos);
end
