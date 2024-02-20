function cmenu=SelectVariable(varargin)

cmenu=uicontextmenu('Tag','SelectVariable');
uimenu(cmenu,'Label','Velocity','Tag','velocity',...
    'Callback',@SetVariable);
uimenu(cmenu,'Label','Phase','Tag','phase',...
    'Callback',@SetVariable);
uimenu(cmenu,'Label','Calc. BIM','Tag','bim',...
    'Callback',@SetVariable);
uimenu(cmenu,'Label','Contrast','Tag','contrast','Enable','off',...
    'Callback',@SetVariable);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function func=SetVariable(varargin)

choice=get(gcbo,'Tag');
hlabel=get(get(gcbo,'Parent'),'UserData');

switch(choice)
    case 'velocity'
        set(hlabel,'String','Velocity');
    case 'phase'
        set(hlabel,'String','Phase');
    case 'bim'
        set(hlabel,'String','Calc. BIM');
    case 'contrast'
        set(hlabel,'String','Contrast');
end

PointVISARGUI('update');
