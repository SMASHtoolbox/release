function zoom(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','zoom','ToolTipString','Zoom',...
            'Cdata',local_graphic('ZoomIcon'),'Separator','on',...
            'ClickedCallback',@callback);
        object.ToolButton.Zoom=h;        
    case 'hide'
        set(object.Button.Zoom,'Visible','off');
    case 'show'
        set(object.Button.Zoom,'Visible','on');
end

    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        if strcmpi(state,'on')
            set(src,'State','on');
            zoom(object.Handle,'on');
        end
    end

end