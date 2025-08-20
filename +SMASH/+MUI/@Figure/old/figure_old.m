% mui.figure : create a MUI figure

%% main function and support functions
function varargout=figure(varargin)

% create figure
fig=figure(varargin{:});

% create toolbar
set(fig,'MenuBar','none','Toolbar','none','DockControls','off');

% create the toolbar
data.figset{1}='Pointer';
data.figset{end+2}='PointerShapeCData';
data.figset{end+2}='PointerShapeHotSpot';
data.figset{end+2}='WindowButtonDownFcn';
data.figset{end+2}='WindowButtonMotionFcn';
data.figset{end+2}='WindowButtonUpFcn';
N=numel(data.figset);
for ii=1:2:N
    data.figset{ii+1}=get(fig,data.figset{ii});
end

hb=uitoolbar('Parent',fig,'Tag','MinimalFigureToolbar','UserData',data);

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

data=[];
data.pointer='crosshair';
data.hotspot=[8 8];
uitoggletool('Parent',hb,'Tag','autoscale',...
    'Cdata',local_graphic('AutoScaleIcon'),'Enable','on',...
    'ClickedCallback',@ToggleButton,...
    'UserData',data,'ToolTipString','Auto scale axes');

data=[];
data.hotspot=[8 8];
data.pointer='crosshair';
uitoggletool('Parent',hb,'Tag','tightscale',...
    'Cdata',local_graphic('TightScaleIcon'),'Enable','on',...
    'ClickedCallback',@ToggleButton,...
    'UserData',data,'ToolTipString','Tight scale axes');

data=[];
data.pointer='crosshair';
data.hotspot=[8 8];
uitoggletool('Parent',hb,'Tag','manualscale',...
    'Cdata',local_graphic('ManualScaleIcon'),'Enable','on',...
    'ClickedCallback',@ToggleButton,...
    'UserData',data,'ToolTipString','Manual scale');

uitoggletool('Parent',hb,'Tag','datacursor','ToolTipString','Data cursor',...
    'Cdata',local_graphic('DatatipIcon'),'Separator','on','Enable','on',...
    'ClickedCallback',@ToggleButton);

data=[];
data.pointer='crosshair';
uitoggletool('Parent',hb,'Tag','ROIstatistics',...
    'ToolTipString','Region of interest (ROI) statistics',...
    'Cdata',local_graphic('ROIicon'),'Enable','on',...
    'UserData',data,'ClickedCallback',@ToggleButton);

data=[];
data.pointer='crosshair';
uitoggletool('Parent',hb,'Tag','overlay',...
    'ToolTipString','Overlay (x,y) data',...
    'Cdata',local_graphic('OverlayIcon'),'Enable','on',...
    'UserData',data,'ClickedCallback',@ToggleButton);

data=[];
data.pointer='crosshair';
uitoggletool('Parent',hb,'Tag','clone',...
    'ToolTipString','Clone axes',...
    'Cdata',local_graphic('CloneIcon'),'Enable','on',...
    'UserData',data,'ClickedCallback',@ToggleButton);

data=[];
data.pointer='crosshair';
uitoggletool('Parent',hb,'Tag','slice',...
    'ToolTipString','Slice image',...
    'Cdata',local_graphic('SliceIcon'),'Enable','on',...
    'UserData',data,'ClickedCallback',@ToggleButton);

uipushtool('Parent',hb,'Tag','help','ToolTipString','Toolbar help',...
    'Cdata',local_graphic('HelpIcon'),'Separator','on','Enable','on',...
    'ClickedCallback',@ButtonClick);



% output control
if nargout>=1
    varargout{1}=fig;
end

end

%% toolbar button callback and suport functions
function ButtonClick(src,varargin)

tag=get(src,'Tag');
switch tag
    case 'directory'
        dirname=uigetdir(pwd,'Select working diretory');
        if isnumeric(dirname) % user pressed cancel
            return
        else
            cd(dirname);
        end
    case 'save'
        % make a temporary figure
        mainfig=ancestor(src,'figure');
        set(mainfig,'Visible','off');
        tempfig=copyobj(mainfig,0);
        % remove all uicontrols/uimenus from temp figure
        h=findall(tempfig,'Type','uicontrol');
        delete(h);
        h=findall(tempfig,'Type','uimenu','-or','Type','uicontextmenu');
        delete(h);
        h=findall(tempfig,'Type','uitoolbar');
        delete(h);
        % restore default behavior to temp figure
        set(tempfig,'ResizeFcn','','WindowButtonDownFcn','',...
            'WindowButtonMotionFcn','','WindowButtonUpFcn','',...
            'KeyPressFcn','','ButtonDownFcn','',...
            'CloseRequestFcn','closereq','HandleVisibility','on',...
            'MenuBar','figure','Toolbar','figure','Pointer','default');
        % save temporary figure, then delete it
        name=sprintf('Saved figure (%s)',datestr(now));
        set(tempfig,'Name',name);
        set(tempfig,'Visible','on');
        filemenufcn(tempfig,'FileSaveAs');
        delete(tempfig);
        set(mainfig,'Visible','on');
    case 'help'
        object=mui.dialog('Name','Toolbar operations');
        object.hide;
        % create message
        indent=repmat(' ',[1 5]);
        indent=[indent '-'];
        message={};
        message{end+1}='Toolbar operations';
        message{end+1}=' ';
        message{end+1}='1. Set working directory';
        message{end+1}=[indent ...
            'Change the current directory using a dialog box.'];
        message{end+1}='2. Save figure';
        message{end+1}=[indent...
            'Save figure as a MATLAB *.fig file or a graphic file (pdf, jpg, etc.).'];
        message{end+1}='3. Zoom';
        message{end+1}=[indent 'Zoom in with mouse click or click and drag.'];
        message{end+1}=[indent 'Zoom out with shift-click; double-click to restore original view.'];
        message{end+1}=[indent 'Press right mouse button (control-click) for additional options.'];
        message{end+1}='4. Pan';
        message{end+1}=[indent 'Click and drag to pan over an axes; double-click to restore original view.'];
        message{end+1}=[indent 'Press right mouse button (control-click) for additional options.'];
        message{end+1}='5. Auto scale';
        message{end+1}=[indent 'Click on axes to set nice limits.'];
        message{end+1}=[indent 'Shift-click to auto scale all figure axes.'];
        message{end+1}='6. Tight scale';
        message{end+1}=[indent 'Click on axes to set tight limit'];
        message{end+1}=[indent 'Shift-click to tight scale all figure axes.'];
        message{end+1}='7. Manual scale ';
        message{end+1}=[indent 'Click on axes to manually set limits.'];
        message{end+1}='8. Data cursor';
        message{end+1}=[indent 'Click on data to display (x,y,z) coordinates.'];
        message{end+1}=[indent 'Press right mouse button (control-click) for additional options.'];
        message{end+1}='9. Region of interest (ROI) statistics ';
        message{end+1}=[indent 'Click and drag to specify a region of interest.'];
        message{end+1}=[indent 'Local statistics in this region will be displayed.'];
        message{end+1}='10. Overlay (x,y) data ';
        message{end+1}=[indent 'Click on axes to overlay (x,y) data from a file.'];
        message{end+1}=[indent 'Right-click overlays to make adjustments.'];
        message{end+1}='11. Clone axes  ';
        message{end+1}=[indent 'Click on axes to clone to another figure.'];
        message{end+1}='12. Slice image  ';
        message{end+1}=[indent 'Click on image to generate horizontal and vertical slice plots. '];
        h=object.text(message);
        extent=get(h,'Extent');
        pos=get(object.Handle,'Position');
        pos(3)=extent(3);
        set(object.Handle,'Position',pos);
        object.show;
        object.lock
end

end


%% toggle callback anad support functions
function ToggleButton(src,varargin)

% get handles
parent=get(src,'Parent');
fig=ancestor(src,'figure');
figure(fig)

% restore figure to default state
zoom(fig,'off');
pan(fig,'off');
datacursormode(fig,'off');
autoscale(fig,'off');
tightscale(fig,'off');
manualscale(fig,'off');
ROIstatistics(fig,'off');
overlay(fig,'off');
clone(fig,'off');
slice(fig,'off');

% check toggle state
state=get(src,'State');
if strcmp(state,'on')
    % turn off other toggle switchs
    toggle=findobj(parent,'Type','uitoggletool');
    ii=(toggle~=src);
    set(toggle(ii),'State','off');
else
    return % nothing left to do
end

% make sure at least one axes exists
haxes=ValidAxes(fig);
if numel(haxes)==0
    set(src,'State','off');
    return
end

% execute specific toggle actions
tag=get(src,'Tag');
switch tag
    case 'zoom'
        zoom(fig,'on');
    case 'pan'
        pan(fig,'on');
    case 'autoscale'
        autoscale(fig,'on');
    case 'tightscale'
        tightscale(fig,'on');
    case 'manualscale'
        manualscale(fig,'on');
    case 'datacursor'
        dcm_obj=datacursormode(fig);
        set(dcm_obj,'Enable','on','UpdateFcn',@datacursor_text)
    case 'ROIstatistics'
        ROIstatistics(fig,'on');
    case 'overlay'
        overlay(fig,'on');
    case 'clone'
        clone(fig,'on');
    case 'slice'
        slice(fig,'on');
end

end

function func=IsValidAxes(haxes)

func=false;
type=get(haxes,'Type');
tag=get(haxes,'Tag');
if ~strcmp(type,'axes')
    return
elseif strcmp(tag,'legend') || strcmp(tag,'colorbar')
    return
else
    func=true;
end

end

function func=ValidAxes(fig)

haxes=findobj(fig,'Type','axes');
N=numel(haxes);
func=[];
for ii=1:N
    if IsValidAxes(haxes(ii))
        func(end+1)=haxes(ii);
    end
end

end

