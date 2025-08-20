function help(object,mode)

switch mode
    case 'create'
        h=uipushtool('Parent',object.ToolBar,...
            'Tag','Help','ToolTipString','Toolbar help',...
            'Cdata',local_graphic('HelpIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.help=h;
    case 'hide'
        set(object.Button.help,'Visible','off');
    case 'show'
        set(object.Button.help,'Visible','on');
end

end

%%
function callback(varargin)

location=mfilename('fullpath');
location=fileparts(location);

SMASH.System.showDocumentation('help.m',location)

end