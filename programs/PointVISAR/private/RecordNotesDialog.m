
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecordNotesDialog(record)

% create dialog (if necessary)
fig=findall(0,'Type','figure','Tag','PointVISAR:Notes');
if ishandle(fig)
    figure(fig);
    notebox=findobj(fig,'Tag','Notes');
else
    % spacing parameters (characters)
    dx=5;
    dy=1;
    ControlHeight=2;
    TextWidth=80;
    TextHeight=20;
    FigWidth=TextWidth+2*dx;
    FigHeight=TextHeight+ControlHeight+3*dy;
    % create figure
    fig=figure('Visible','off',...
        'MenuBar','none','Toolbar','none',...
        'Tag','RecordNotesDialog','Resize','off',...
        'NumberTitle','off','Name','Record notes',...
        'Units','characters','Position',[0 0 FigWidth FigHeight],...
        'CloseRequestFcn',@ExitDialog);
    movegui(fig,'center');
    figure(fig);
    figpos=get(fig,'Position');
    % record notes edit box
    x0=dx;
    y0=figpos(4)-dy-TextHeight;
    notebox=uicontrol('Style','edit',...
        'Tag','Notes',...
        'HorizontalAlignment','left',...
        'Min',0,'Max',2,...
        'BackgroundColor',[1 1 1],...
        'Units','characters','Position',[x0 y0 TextWidth TextHeight]);
    % ok/cancel buttons at the bottom
    y0=dy;
    cancel=uicontrol('Style','pushbutton',...
        'String','Cancel','Tag','cancel','Units','characters');
    extent=get(cancel,'Extent');
    width=1.25*extent(3);
    x0=figpos(3)-dx-width;
    set(cancel,'Position',[x0 y0 width ControlHeight]);
    ok=uicontrol('Style','pushbutton',...
        'String','OK','Tag','ok','Units','characters');
    x0=x0-dx/2-width;
    set(ok,'Position',[x0 y0 width ControlHeight]);
    set([ok cancel],'Callback',@ExitDialog);
    children=[notebox ok cancel];
    set(fig,'Children',children(end:-1:1));
    % protect figure from command line
    set(fig,'HandleVisibility','callback');
end

% store necessary information and update list selection
set(notebox,'String',record.Notes);
hc=findobj(fig,'Type','uicontrol');
set(hc,'FontName','fixed');

%%%%%%%%%%%%%
% callbacks %
%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExitDialog(src,varargin)

fig=ancestor(src,'figure');
main=findall(0,'Type','figure','Tag','PointVISAR:ReadEditRecord');

choice=get(src,'Tag');
if strcmp(choice,'ok') % user chose OK button
    record=get(main,'UserData');
    notebox=findobj(fig,'Tag','Notes');
    record.Notes=get(notebox,'String');
    set(main,'UserData',record);    
    delete(fig);
    figure(main);
    return
end

% see if the user is serious about cancel
prompt{1}='All note changes be lost! Continue?';
answer=questdlg(prompt,'Cancel notes?');
if strcmpi(answer,'yes')
    delete(fig);
    figure(main)
else
    return
end