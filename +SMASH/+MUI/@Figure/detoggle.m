function detoggle(object)

% determine number of active toggles
h=findobj(object.ToolBar,'Type','uitoggletool');
N=0;
for k=1:numel(h)
    state=get(h(k),'State');
    if strcmpi(state,'on')
        N=N+1;
    end
end

% deactivate toggle-able states
fig=object.Handle;
set(h,'state','off');
zoom(fig,'off');
pan(fig,'off');
datacursormode(fig,'off');

% manage figure settings
if N==1    % new toggle--store current state for later use
    object.Pointer=get(fig,'Pointer');
    object.PointerShapeCData=get(fig,'PointerShapeCData');
    object.WindowButtonDownFcn=get(fig,'WindowButtonDownFcn');
    object.WindowButtonMotionFcn=get(fig,'WindowButtonMotionFcn');
    object.WindowButtonUpFcn=get(fig,'WindowButtonUpFcn');
    object.ButtonDownFcn=get(fig,'ButtonDownFcn');
else
    set(fig,'Pointer',object.Pointer);
    set(fig,'PointerShapeCData',object.PointerShapeCData);
    set(fig,'WindowButtonDownFcn',object.WindowButtonDownFcn);
    set(fig,'WindowButtonMotionFcn',object.WindowButtonMotionFcn);
    set(fig,'WindowButtonUpFcn',object.WindowButtonUpFcn);
    set(fig,'ButtonDownFcn',object.ButtonDownFcn');
end

end