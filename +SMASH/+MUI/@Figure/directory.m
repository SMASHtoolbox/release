function directory(object,mode)

switch mode
    case 'create'
        h=uipushtool('Parent',object.ToolBar,'Tag','directory',...
            'ToolTipString','Set current directory',...
            'CData',local_graphic('FolderIcon'),...
            'ClickedCallback',@callback);
        object.ToolButton.Director=h;
    case 'hide'
        set(object.Button.Directory,'Visible','off');
    case 'show'   
        set(object.Button.Directory,'Visible','on');
end

    function callback(varargin)
        dirname=uigetdir(pwd,'Select working diretory');
        if isnumeric(dirname) % user pressed cancel
            return
        else
            cd(dirname);
        end
    end

end