function pan(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','pan','ToolTipString','Pan',...
            'Cdata',local_graphic('PanIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.Pan=h;        
    case 'hide'
        set(object.Button.Pan,'Visible','off');
    case 'show'
        set(object.Button.Pan,'Visible','on');
end

    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        if strcmpi(state,'on')
            set(src,'State','on');
            pan(object.Handle,'on');
        end
    end

end