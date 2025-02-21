function NudgeTextBoxes(fig)

h=findobj(fig,'Type','uicontrol','Style','text');
for k=1:numel(h)
    string=get(h(k),'String');
    set(h(k),'String','');
    pos=get(h(k),'Position');
    extent=get(h(k),'Extent');
    pos(2)=pos(2)-2*extent(4);
    set(h(k),'Position',pos,'String',string);
end
