function toolbar(fig)

% handle input
if (nargin<1) || isempty(fig)
    fig=gcf;
end

% create toolbar
data=[];
hb=uitoolbar('Parent',fig,'Tag','MinimalFigureToolbar','UserData',data,...
    'DeleteFcn',@DeleteMinimalFigure);

% create push buttons
uipushtool('Parent',hb,'Tag','directory',...
    'ToolTipString','Set working directory',...
    'CData',local_graphic('FolderIcon'),'ClickedCallback',@ButtonClick);

uipushtool('Parent',hb,'Tag','save','ToolTipString','Save figure',...
    'Cdata',local_graphic('SaveIcon'),'ClickedCallback',@ButtonClick);%,'Visible','off');

uitoggletool('Parent',hb,'Tag','zoom','ToolTipString','Zoom',...
    'Cdata',local_graphic('ZoomIcon'),'Separator','on',...
    'ClickedCallback',@ToggleButton);

uitoggletool('Parent',hb,'Tag','pan','ToolTipString','Pan',...
    'Cdata',local_graphic('PanIcon'),...
    'ClickedCallback',@ToggleButton);

% callbacks

end