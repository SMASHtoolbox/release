function standard(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','standard','ToolTipString','Show standard toolbar',...
            'Cdata',local_graphic('StandardIcon'),...
            'ClickedCallback',@callback);
        object.ToolButton.Standard=h;        
    case 'hide'
        set(object.Button.Standard,'Visible','off');
    case 'show'
        set(object.Button.Standard,'Visible','on');
end

    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        if strcmpi(state,'on')
            set(src,'State','on',...
                'ToolTipString','Hide standard toolbar');
            set(object.Handle,'Toolbar','figure');
        else
            set(src,'State','off',...
                'ToolTipString','Show standard toolbar');
            set(object.Handle,'Toolbar','none');
        end
    end


end