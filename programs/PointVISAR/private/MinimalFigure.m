% MinimalFigure: create a minimalistic figure useful for GUIs
%
% This function creates a MATLAB non-dockable, menu-less figure with a
% custom toolbar.  Aside from these customizations, all standard figure
% features can be specified as inputs:
% MinimalFigure('Units','pixels','Position',[0 0 600 480]); % example
% or through handle graphics operations.  The purpose of this function is
% to provide a clean interface for building GUI programs, omitting
% extraneous menu items, potentially dangerous operations (such as renaming
% or deleting an axes), and non-compilable features.
%
% Icons needed for the function are stored in the file CustomIcons.mat.

% created 1/4/2007 by Daniel Dolan
% updated 2/15/2007
% updated 1/31/2010 by Daniel Dolan
%   -added overlay and clone capabilties
% updated 2/1/2010 by Daniel Dolan
%   -revised the toolbar (icon appearance)

function varargout=MinimalFigure(varargin)

% create figure
fig=figure(varargin{:});
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

hb=uitoolbar('Parent',fig,'Tag','MinimalFigureToolbar','UserData',data,...
    'DeleteFcn',@DeleteMinimalFigure);

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
uitoggletool('Parent',hb,'Tag','PeakFinder',...
    'ToolTipString','Peak Finder',...
    'Cdata',local_graphic('PeakIcon'),'Enable','off',...
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

uipushtool('Parent',hb,'Tag','help','ToolTipString','Toolbar help',...
    'Cdata',local_graphic('HelpIcon'),'Separator','on','Enable','on',...
    'ClickedCallback',@ButtonClick);

% output control
if nargout>0
    varargout{1}=fig;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% toolbar button callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        %name=get(tempfig,'Name');
        name=sprintf('Saved figure (%s)',datestr(now));
        set(tempfig,'Name',name);
        set(tempfig,'Visible','on');
        filemenufcn(tempfig,'FileSaveAs');
        delete(tempfig);
        set(mainfig,'Visible','on');
    case 'help'
        HelpDialog;
        %msgbox(message,'Toolbar operations');
        %ht=findobj(h,'Tag','MessageBox');
        %set(ht,'FontName','fixed');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% toolbar toggle callbacks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
PeakFinder(fig,'off');
overlay(fig,'off');
clone(fig,'off');

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
    case 'PeakFinder'
        PeakFinder(fig,'on');
    case 'overlay'
        overlay(fig,'on');
    case 'clone'
        clone(fig,'on');
end

end
%%%%%%%%%%%%%%%%%%%%%
% general functions %
%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HelpDialog()
% create message
indent=repmat(' ',[1 5]);
indent=[indent '-'];
message={};
message{end+1}='Toolbar operations';
message{end+1}=' ';
message{end+1}='1. Set working directory';
message{end+1}=[indent ...
    'Change the current directory using a dialog box.'];
message{end+1}=' ';
message{end+1}='2. Save figure';
message{end+1}=[indent...
    'Save figure as a MATLAB *.fig file or a graphic file (pdf, jpg, etc.).'];
message{end+1}=' ';
message{end+1}='3. Zoom';
message{end+1}=[indent 'Zoom in with mouse click or click and drag.'];
message{end+1}=[indent 'Zoom out with shift-click; double-click to restore original view.'];
message{end+1}=[indent 'Press right mouse button (control-click) for additional options.'];
message{end+1}=' ';
message{end+1}='4. Pan';
message{end+1}=[indent 'Click and drag to pan over an axes; double-click to restore original view.'];
message{end+1}=[indent 'Press right mouse button (control-click) for additional options.'];
message{end+1}=' ';
message{end+1}='5. Auto scale';
message{end+1}=[indent 'Click on axes to set nice limits.'];
message{end+1}=[indent 'Shift-click to auto scale all figure axes.'];
message{end+1}=' ';
message{end+1}='6. Tight scale';
message{end+1}=[indent 'Click on axes to set tight limit'];
message{end+1}=[indent 'Shift-click to tight scale all figure axes.'];
message{end+1}=' ';
message{end+1}='7. Manual scale ';
message{end+1}=[indent 'Click on axes to manually set limits.'];
message{end+1}=' ';
message{end+1}='8. Data cursor';
message{end+1}=[indent 'Click on data to display (x,y,z) coordinates.'];
message{end+1}=[indent 'Press right mouse button (control-click) for additional options.'];
message{end+1}=' ';
message{end+1}='9. Region of interest (ROI) statistics ';
message{end+1}=[indent 'Click and drag to specify a region of interest.'];
message{end+1}=[indent 'Local statistics in this region will be displayed.'];
message{end+1}=' ';
message{end+1}='10. Peak finder ';
message{end+1}=[indent 'Click and drag to specify region containing one peak (per signal)'];
message{end+1}=[indent 'Peak locations determined by Gaussian fit.'];
message{end+1}=' ';
message{end+1}='11. Overlay (x,y) data ';
message{end+1}=[indent 'Click on axes to overlay (x,y) data from a file.'];
message{end+1}=[indent 'Right-click overlays to make adjustments.'];
message{end+1}=' ';
message{end+1}='12. Clone axes  ';
message{end+1}=[indent 'Click on axes to clone to another figure.'];
message{end+1}=' ';
numlines=numel(message);
width=0;
for ii=1:numlines
    width=max([width numel(message{ii})]);
end
% create dialog
fig=findall(0,'Type','figure','Tag','MinimalFigure:Help');
if ishandle(fig)
    delete(fig);
end
fig=figure('Toolbar','none','Menubar','none','DockControls','off',...
    'Tag','MinimalFigure:Help','Visible','off',...
    'Units','characters','Resize','off',...
    'IntegerHandle','off','HandleVisibility','callback',...
    'NumberTitle','off','Name','Toolbar help');

gset=GUIsettings;
htext=uicontrol('Style','text',...
    'Units','characters','Position',[0 0 80 1],...
    'HorizontalAlignment','left',...
    'Max',2,'Min',0,'BackgroundColor',gset.textbgcolor);
[message,pos]=textwrap(htext,message);
figpos=[0 0 pos(3)+2*gset.hmargin pos(4)+2*gset.vmargin];

pos(1)=pos(1)+gset.hmargin;
pos(2)=pos(2)+gset.vmargin;
set(htext,'String',message,'Position',pos);

set(fig,'Position',figpos);
movegui(fig,'center');
set(fig,'Visible','on');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autoscale(fig,mode)

toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','autoscale');
switch mode
    case 'on'
        haxes=ValidAxes(fig);
        if numel(haxes)>1
            data=get(toggle,'UserData');
            %set(fig,'Pointer','custom','PointerShapeCData',data.pointer,...
            %    'PointerShapeHotSpot',data.hotspot,...
            %    'WindowButtonUpFcn',@autoscaleCallback);
            set(fig,'Pointer',data.pointer,'WindowButtonUpFcn',@autoscaleCallback);
        else
            if numel(haxes)==1;
                axis(haxes,'auto');
            end
            set(toggle,'State','off'); % for user convenience
        end
    case 'off'
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
end
end

function autoscaleCallback(src,varargin)

fig=ancestor(src,'figure');
toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','autoscale');
selection=get(fig,'SelectionType');
switch lower(selection)
    case 'normal'
        ha=get(fig,'CurrentAxes');
        if IsValidAxes(ha)
            axis(ha,'auto');
        end
    case 'extend'
        haxes=ValidAxes(fig);
        N=numel(haxes);
        for ii=1:N
            axis(haxes(ii),'auto');
        end
        autoscale(fig,'off');
        set(toggle,'State','off'); % for user convenience
end
zoom(fig,'reset');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tightscale(fig,mode)

toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','tightscale');
switch mode
    case 'on'
        haxes=ValidAxes(fig);
        if numel(haxes)>1
            data=get(toggle,'UserData');
            %set(fig,'Pointer','custom','PointerShapeCData',data.pointer,...
            %    'PointerShapeHotSpot',data.hotspot,...
            %    'WindowButtonUpFcn',@tightscaleCallback);
            set(fig,'Pointer',data.pointer,'WindowButtonUpFcn',@tightscaleCallback);
        else
            if numel(haxes)==1;
                axis(haxes,'tight');
            end
            set(toggle,'State','off'); % for user convenience
        end
    case 'off'
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
end
end

function tightscaleCallback(src,varargin)

fig=ancestor(src,'figure');
toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','tightscale');
selection=get(fig,'SelectionType');
switch lower(selection)
    case 'normal'
        ha=get(fig,'CurrentAxes');
        if IsValidAxes(ha)
            axis(ha,'tight');
        end
    case 'extend'
        haxes=ValidAxes(fig);
        N=numel(haxes);
        for ii=1:N
            axis(haxes(ii),'tight');
        end
        tightscale(fig,'off');
        set(toggle,'State','off'); % for user convenience
end
zoom(fig,'reset');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function manualscale(fig,mode)

toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','manualscale');
switch mode
    case 'on'
        haxes=ValidAxes(fig);
        if numel(haxes)>1
            data=get(toggle,'UserData');
            %set(fig,'Pointer','custom','PointerShapeCData',data.pointer,...
            %    'PointerShapeHotSpot',data.hotspot,...
            %    'WindowButtonUpFcn',@manualscaleCallback);
            set(fig,'Pointer',data.pointer,'WindowButtonUpFcn',@manualscaleCallback);
        else
            manualscaleCallback(fig);
            set(toggle,'State','off'); % for user convenience
            set(haxes,'Selected','off');
        end
    case 'off'
        dlg=findall(0,'Type','figure','Tag','MinimalFigure:ManualScale');
        delete(dlg);
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
        haxes=findall(fig,'Type','axes');
        set(haxes,'Selected','off');
end

end

function manualscaleCallback(src,varargin)

mainfig=ancestor(src,'figure');

% probe axes's current state
haxes=get(mainfig,'CurrentAxes');
temp=axis(haxes);
Naxis=numel(temp)/2;
oldlim=cell(1,Naxis);
for ii=1:Naxis
    oldlim{ii}=temp(1:2);
    temp=temp(3:end);
end
hc=findall(mainfig,'Type','axes');
set(hc,'Selected','off');
set(haxes,'Selected','on')

% see if dialog box already exists
fig=findall(0,'Type','figure','Tag','MinimalFigure:ManualScale');
if ishandle(fig)
    set(fig,'Units','characters');
    pos=get(fig,'Position'); % store previous location
    delete(fig);
else
    oldunits=get(mainfig,'Units');
    set(mainfig,'Units','characters');
    pos=get(mainfig,'Position');
    set(mainfig,'Units',oldunits);
end

% create new dialog box
gset=GUIsettings;
Ly=Naxis*gset.textheight+gset.buttonheight+(Naxis+2)*gset.vmargin;
Lx=2*(gset.editwidth+gset.labelwidth)+gset.checkwidth+2*gset.hmargin;
pos(3)=Lx;
pos(4)=Ly;
fig=figure('IntegerHandle','off',...
    'Tag','MinimalFigure:ManualScale',...
    'units','characters','Position',pos,...
    'NumberTitle','off','Name','Manual scale axes',...
    'Menubar','none','DockControls','off',...
    'Resize','off');
% create limit controls for each axis
label={'x=','y=','z='};
checktag={'autox','autoy','autoz'};
for ii=1:Naxis
    pos(1)=gset.hmargin;
    pos(2)=Ly-ii*(gset.vmargin+gset.textheight);
    pos(3)=gset.labelwidth;
    pos(4)=gset.textheight;
    %pos=[dx Ly-ii*(dx+ControlHeight) LabelWidth ControlHeight];
    uicontrol('Style','text','String',label{ii},...
        'Units','characters','Position',pos);
    pos(1)=pos(1)+pos(3);
    pos(3)=gset.editwidth;
    edit1=uicontrol('Style','edit',...
        'Units','characters','Position',pos,...
        'Tag','edit','Callback',@ManualScaleUpdate);
    ManualScaleWriter(edit1,oldlim{ii}(1));
    pos(1)=pos(1)+pos(3);
    pos(3)=gset.labelwidth;
    uicontrol('Style','text','String','to',...
        'Units','characters','Position',pos);
    pos(1)=pos(1)+pos(3);
    pos(3)=gset.editwidth;
    edit2=uicontrol('Style','edit',...
        'Units','characters','Position',pos,...
        'Tag','edit','Callback',@ManualScaleUpdate);
    ManualScaleWriter(edit2,oldlim{ii}(2));
    pos(1)=pos(1)+pos(3);
    pos(3)=gset.checkwidth;
    autobox=uicontrol('Style','checkbox','String','Auto',...
        'units','characters','Position',pos,...
        'Tag',checktag{ii},'Callback',@ManualScaleUpdate);
    edit{ii}=[edit1 edit2];
    set(edit{ii},'UserData',autobox);
    set(autobox,'UserData',edit{ii});
end
% OK push button
%pos(1)=Lx-3*ButtonWidth-3*dx;
pos(1)=Lx-3*gset.buttonwidth-3*gset.hmargin;
pos(2)=gset.vmargin;
pos(3)=gset.buttonwidth;
pos(4)=gset.buttonheight;
uicontrol('Style','pushbutton','Tag','ok',...
    'Units','characters','Position',pos,...
    'String','OK','Callback',@ManualScaleUpdate);
% apply push button
pos(1)=pos(1)+gset.buttonwidth+gset.hmargin;
apply=uicontrol('Style','pushbutton','Tag','apply',...
    'Units','characters','Position',pos,...
    'String','Apply','Callback',@ManualScaleUpdate);
set(apply,'UserData',edit);
% cancel push button
pos(1)=pos(1)+gset.buttonwidth+gset.hmargin;
uicontrol('Style','pushbutton','Tag','cancel',...
    'Units','characters','Position',pos,...
    'String','Cancel','Callback',@ManualScaleUpdate);
% appearance formatting
h=findobj(fig,'Type','uicontrol');
set(h,'FontName',gset.fontname);
h=findobj(fig,'Style','text');
set(h,'BackgroundColor',gset.textbgcolor);
h=findobj(fig,'Style','checkbox');
set(h,'BackgroundColor',gset.textbgcolor);
h=findobj('Style','edit');
set(h,'BackgroundColor',gset.editcolor);
% store data in dialog for later use
data.haxes=haxes;
data.Naxis=numel(oldlim);
data.oldlim=oldlim;
data.newlim=oldlim;
set(fig,'UserData',data);
% protect figure from console
set(fig,'HandleVisibility','callback');

end
function ManualScaleUpdate(src,varargin)

fig=findall(0,'Type','figure','Tag','MinimalFigure:ManualScale');
data=get(fig,'UserData');
limfield={'XLim','YLim','ZLim'};

if ishandle(src)
    tag=get(src,'Tag');
else
    tag=src;
    src=findobj(fig,'Tag',tag);
end

switch tag
    case 'edit'
        autobox=get(src,'UserData');
        value=get(autobox,'Min');
        set(autobox,'Value',value);
    case 'autox'
        edit=get(src,'UserData');
        set(data.haxes,'XLimMode','auto');
        newlim=get(data.haxes,'XLim');
        ManualScaleWriter(edit,newlim);
        data.newlim{1}=newlim;
        set(fig,'UserData',data);
    case 'autoy'
        edit=get(src,'UserData');
        set(data.haxes,'YLimMode','auto');
        newlim=get(data.haxes,'YLim');
        ManualScaleWriter(edit,newlim);
        data.newlim{2}=newlim;
        set(fig,'UserData',data);
    case 'autox'
        edit=get(src,'UserData');
        set(data.haxes,'ZLimMode','auto');
        newlim=get(data.haxes,'ZLim');
        ManualScaleWriter(edit,newlim);
        data.newlim{3}=newlim;
        set(fig,'UserData',data);
    case 'ok'
        ManualScaleUpdate('apply');
        ManualScaleUpdate('done');
        targetfig=ancestor(data.haxes,'figure');
        zoom(targetfig,'reset');
    case 'apply'
        for ii=1:data.Naxis
            edit=get(src,'UserData');
            newlim=data.newlim{ii};
            newlim=ManualScaleReader(edit{ii},newlim);
            set(data.haxes,limfield{ii},newlim);
            data.newlim{ii}=newlim;
            set(fig,'UserData',data);
        end
    case 'cancel'
        for ii=1:data.Naxis
            set(data.haxes,limfield{ii},data.oldlim{ii});
        end
        ManualScaleUpdate('done');
    case 'done'
        delete(fig);
        return;
end

    function ManualScaleWriter(editbox,value)
        N=numel(editbox);
        for kk=1:N
            set(editbox(kk),'String',sprintf('%.6g',value(kk)));
        end
        
    end
    function func=ManualScaleReader(editbox,default)
        func=default;
        [data1,count1]=sscanf(get(editbox(1),'String'),'%g');
        [data2,count2]=sscanf(get(editbox(2),'String'),'%g');
        if count1>0
            func(1)=data1(1);
        end
        if count2>0
            func(2)=data2(1);
        end
        none=(count1==0)|(count2==0);
        many=(count1>1)|(count2>1);
        if none || many
            message{1}='Warning: invalid axis limits specified!';
            message{2}='Some axis limits empty and/or multi-valued.';
            message{3}='Previous or first value(s) used as appropriate';
            warndlg(message,'Invalid axis limits');
            set(editbox(1),'String',sprintf('%.6g',func(1)));
            set(editbox(2),'String',sprintf('%.6g',func(2)));
        elseif func(2)<=func(1)
            message{1}='Warning: invalid axis limits specified!';
            message{2}='Left limit(s) must be greater than right limit(s)';
            message{3}='Previous values used';
            warndlg(message,'Invalid axis limits');
            func=default;
            set(editbox(1),'String',sprintf('%.6g',func(1)));
            set(editbox(2),'String',sprintf('%.6g',func(2)));
        end
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output_txt = datacursor_text(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).


pos = get(event_obj,'Position');
x=pos(1);
output_txt{1}=sprintf('X: %+.6g',x);
y=pos(2);
output_txt{2}=sprintf('Y: %+.6g',y);

target=get(event_obj,'Target');
switch get(target,'Type')
    case 'image'
        zdata=get(target,'CData');
        [M,N]=size(zdata);
        xdata=get(target,'XData');
        xdata=linspace(xdata(1),xdata(end),N);
        ydata=get(target,'YData');
        ydata=linspace(ydata(1),ydata(end),M);
        z=interp2(xdata,ydata,zdata,x,y,'nearest');
        output_txt{3}=sprintf('Z: %+.6g',z);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ROIstatistics(fig,mode)

toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','ROIstatistics');
switch mode
    case 'on'
        data=get(toggle,'UserData');
        set(fig,'WindowButtonDownFcn',@ROIstatisticsBox,...
            'Pointer',data.pointer);
    case 'off'
        dlg=findall(0,'Type','figure','Tag','MinimalFigure:ROIstatistics');
        delete(dlg);
        hbox=findobj(fig,'Tag','ROIstatisticsBox');
        delete(hbox);
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
end

end
function ROIstatisticsBox(src,varargin)

% handles
mainfig=ancestor(src,'figure');
haxes=get(mainfig,'CurrentAxes');
% user highlights ROI
hbox=findobj(mainfig,'Tag','ROIstatisticsBox');
delete(hbox);

old=get(mainfig,'HandleVisibility');
set(mainfig,'HandleVisibility','on');
point1=get(haxes,'CurrentPoint');
rbbox;
point2=get(haxes,'CurrentPoint');
set(mainfig,'HandleVisibility',old);
x=[point1(1,1) point2(1,1)];
y=[point1(1,2) point2(1,2)];
if (diff(x)==0) || (diff(y)==0) % user made a zero area rectangle
    return
end
xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
rectangle('Position',[xmin ymin xmax-xmin ymax-ymin],...
    'LineStyle','--','Tag','ROIstatisticsBox');

% extract data
hc=findobj(haxes,'Type','line','-or','Type','image');
N=numel(hc);
for ii=N:-1:1
    if strcmp(get(hc(ii),'Visible'),'off')
        continue
    end
    x=get(hc(ii),'XData');
    y=get(hc(ii),'YData');
    label={};
    label{end+1}=sprintf(' Horizontal range: %+g to %+g ',xmin,xmax);
    label{end+1}=sprintf(' Vertical range: %+g to %+g ',ymin,ymax);
    switch get(hc(ii),'Type')
        case 'line'
            % check for data inside ROI
            k=(x>=xmin)&(x<=xmax)&(y>=ymin)&(y<=ymax);
            if ~any(k)
                continue
            end
            x=x(k);
            y=y(k);
            % create ROI report
            fig=figure('NumberTitle','off','Name','ROI line statistics',...
                'IntegerHandle','off','HandleVisibility','callback',...
                'Tag','MinimalFigure:ROIstatistics',...
                'Toolbar','none','Menubar','none','DockControls','off',...
                'Units','pixels','Resize','off');
            ha=axes('Parent',fig,'Box','on','Units','pixels',...
                'XTick',[],'YTick',[]);
            hl=line('Parent',ha,'XData',x,'YData',y);
            linkprop([hc(ii) hl],{'Color','LineWidth','LineStyle','Marker'});
            label{end+1}='';
            label{end+1}=sprintf(' Horizontal mean: %+g ',mean(x));
            label{end+1}=sprintf(' Horizontal deviation: %+g ',std(x));
            label{end+1}='';
            label{end+1}=sprintf(' Vertical mean: %+g ',mean(y));
            label{end+1}=sprintf(' Vertical deviation: %+g ',std(y));
            %a=polyfit(x(k),y(k),1);
            %label{end+1}=sprintf('Slope: %+g',a(1));
        case 'image'
            % check for data inside ROI
            z=get(hc(ii),'CData');
            [M,N]=size(z);
            x=linspace(x(1),x(end),N);
            y=linspace(y(1),y(end),M);
            kx=(x>=xmin)&(x<=xmax);
            if ~any(kx)
                continue
            end
            ky=(y>=ymin)&(y<=ymax);
            if ~any(ky)
                continue
            end
            x=x(kx);
            y=y(ky);
            z=z(ky,kx);
            if any(size(z)<1)
                continue
            end
            % create ROI report
            fig=figure('NumberTitle','off','Name','ROI image statistics',...
                'IntegerHandle','off','HandleVisibility','callback',...
                'Tag','MinimalFigure:ROIstatistics',...
                'Toolbar','none','Menubar','none','DockControls','off',...
                'Units','pixels','Resize','off');
            src_fig=ancestor(hc(ii),'figure');
            linkprop([src_fig fig],'ColorMap');
            ha=axes('Parent',fig,'Box','on','Units','pixels');
            hi=imagesc('Parent',ha,'Xdata',x,'YData',y,'CData',z);
            set(ha,'XTick',[],'YTick',[]);
            src_axes=ancestor(hc(ii),'axes');
            linkprop([src_axes ha],{'CLim','YDir'});
            label{end+1}='';
            label{end+1}=sprintf(' Image level mean: %+g ',mean(z(:)));
            label{end+1}=sprintf(' Image level deviation: %+g ',std(z(:)));
            try
                weight=mean(z,1);
                weight=weight/trapz(x,weight);
                CM=trapz(x(:),x(:).*weight(:));
            catch
                CM=nan;
            end
            label{end+1}='';
            label{end+1}=sprintf('Horizontal center: %+g',CM);
            try
                weight=mean(z,2);
                weight=weight/trapz(y,weight);
                CM=trapz(y(:),y(:).*weight(:));
            catch
                CM=nan;
            end
            label{end+1}=sprintf('Vertical center: %+g',CM);
    end
    % format report figure
    axis(ha,'tight');
    xlim(ha,[xmin xmax]);
    ylim(ha,[ymin ymax]);
    
    ht=uicontrol('Parent',fig,'Style','text','Units','pixels',...
        'HorizontalAlignment','left','String',label,...
        'BackgroundColor',get(fig,'Color'));
    extent=get(ht,'Extent');
    Lx=extent(3);
    Ly=extent(4);
    set(ht,'Position',[Ly 0 Lx Ly]);
    gap=5; % pixels
    set(ha,'Position',[gap gap Ly-2*gap Ly-2*gap]);%,...
    %'PlotBoxAspectRatio',[(xmax-xmin) (ymax-ymin) 1]);
    pos=get(fig,'Position');
    pos(3)=Ly+Lx;
    pos(4)=Ly;
    set(fig,'Position',pos);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PeakFinder(fig,mode)

toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','PeakFinder');
switch mode
    case 'on'
        data=get(toggle,'UserData');
        set(fig,'WindowButtonDownFcn',@PeakFinderBox,...
            'Pointer',data.pointer);
    case 'off'
        dlg=findall(0,'Type','figure','Tag','MinimalFigure:PeakFinder');
        delete(dlg);
        hbox=findobj(fig,'Tag','PeakFinderBox');
        delete(hbox);
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
end

end

function PeakFinderBox(src,varargin)
% handles
mainfig=ancestor(src,'figure');
haxes=get(mainfig,'CurrentAxes');
% user highlights ROI
hbox=findobj(mainfig,'Tag','PeakFinderBox');
delete(hbox);

old=get(mainfig,'HandleVisibility');
set(mainfig,'HandleVisibility','on');
point1=get(haxes,'CurrentPoint');
rbbox;
point2=get(haxes,'CurrentPoint');
set(mainfig,'HandleVisibility',old);
x=[point1(1,1) point2(1,1)];
y=[point1(1,2) point2(1,2)];
if (diff(x)==0) || (diff(y)==0) % user made a zero area rectangle
    return
end
xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
rectangle('Position',[xmin ymin xmax-xmin ymax-ymin],...
    'LineStyle','--','Tag','PeakFinderBox');

% extract data
hc=findobj(haxes,'Type','line','-or','Type','image');
N=numel(hc);
for ii=N:-1:1
    if strcmp(get(hc(ii),'Visible'),'off')
        continue
    end
    x=get(hc(ii),'XData');
    y=get(hc(ii),'YData');
    label={};
    %label{end+1}=sprintf(' Horizontal range: %+g to %+g ',xmin,xmax);
    %label{end+1}=sprintf(' Vertical range: %+g to %+g ',ymin,ymax);
    switch get(hc(ii),'Type')
        case 'line'
            % check for data inside ROI
            k=(x>=xmin)&(x<=xmax)&(y>=ymin)&(y<=ymax);
            if ~any(k)
                continue
            end
            x=x(k);
            y=y(k);
            [params,fit]=gaussianfit(x,y);
            % create report
            fig=figure('NumberTitle','off','Name','Peak finder',...
                'IntegerHandle','off','HandleVisibility','callback',...
                'Tag','MinimalFigure:PeakFinder',...
                'Toolbar','none','Menubar','none','DockControls','off',...
                'Units','pixels','Resize','off');
            ha=axes('Parent',fig,'Box','on','Units','pixels',...
                'XTick',[],'YTick',[]);
            hl=line('Parent',ha,'XData',x,'YData',y);            
            linkprop([hc(ii) hl],{'Color','LineWidth','LineStyle','Marker'});
            line('Parent',ha,'XData',x,'YData',fit,'Color','k');
            label{end+1}='';
            label{end+1}='';
            label{end+1}=sprintf(' Peak position: %+g ',params(3));
            label{end+1}=sprintf(' Peak width: %+g ',params(4));             
            label{end+1}='';
            label{end+1}='';
    end
    % format report figure
    axis(ha,'tight');
    %xlim(ha,[xmin xmax]);
    %ylim(ha,[ymin ymax]);
    
    ht=uicontrol('Parent',fig,'Style','text','Units','pixels',...
        'HorizontalAlignment','left','String',label,...
        'BackgroundColor',get(fig,'Color'));
    extent=get(ht,'Extent');
    Lx=extent(3);
    Ly=extent(4);
    set(ht,'Position',[Ly 0 Lx Ly]);
    gap=5; % pixels
    set(ha,'Position',[gap gap Ly-2*gap Ly-2*gap]);%,...
    %'PlotBoxAspectRatio',[(xmax-xmin) (ymax-ymin) 1]);
    pos=get(fig,'Position');
    pos(3)=Ly+Lx;
    pos(4)=Ly;
    set(fig,'Position',pos);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function overlay(fig,mode)

toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','overlay');
switch mode
    case 'on'
        haxes=ValidAxes(fig);
        if numel(haxes)>1
            data=get(toggle,'UserData');
            set(fig,'WindowButtonUpFcn',@overlayCallback,...
                'Pointer',data.pointer);
        else
            if numel(haxes)==1;
                set(fig,'CurrentObject',haxes);
                overlayCallback(haxes);
            end
            set(toggle,'State','off'); % for user convenience
        end
    case 'off'
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
end

end
function overlayCallback(src,varargin)

% verify normal axes click
fig=ancestor(src,'figure');
selection=get(fig,'SelectionType');
if ~strcmpi(selection,'normal')
    return
end

target=get(fig,'CurrentObject');
target=ancestor(target,'axes');
if ~ishandle(target)
    return
end

% load data
[filename,pathname]=uigetfile('*.*','Select (x,y) data file');
if isnumeric(filename)
    return
else
    filename=fullfile(pathname,filename);
end

try
    temp=ColumnReader(filename,[],2);
    data.x=temp(:,1);
    data.y=temp(:,2);
    
catch
    errordlg('ERROR: unable to read data file','File error');
    return
end

% create overlay line (with context menu)
data.scale=[1 1];
data.shift=[0 0];
data.color='k';
data.linewidth=0.5;
[pname,name,ext]=fileparts(filename);
data.name=[name ext];
hl=line('Parent',target,'UserData',data,'Tag','overlay_line');

hm=uicontextmenu('Tag','overlay');
set(hl,'UIContextMenu',hm);
uimenu(hm,'Label','Overlay file:','Enable','off');
%label=sprintf('%s overlay',name);
uimenu(hm,'Label',data.name,'Enable','off');
uimenu(hm,'Label','Scale overlay','Tag','scale',...
    'Callback',{@update_overlay,hl},'Separator','on');
uimenu(hm,'Label','Shift overlay','Tag','shift',...
    'Callback',{@update_overlay,hl});
uimenu(hm,'Label','Remove overlay','Tag','delete',...
    'Callback',{@update_overlay,hl});
uimenu(hm,'Label','Set overlay color','Tag','color',...
    'Callback',{@update_overlay,hl},'Separator','on');
uimenu(hm,'Label','Set overlay width','Tag','width',...
    'Callback',{@update_overlay,hl});
update_overlay([],[],hl);
end

function update_overlay(varargin)

hl=varargin{3};
data=get(hl,'UserData');

src=varargin{1};
if ishandle(src)
    tag=get(src,'Tag');
    switch lower(tag)
        case 'scale'
            default{1}=sprintf('%g',data.scale(1));
            default{2}=sprintf('%g',data.scale(2));
            label{1}='Horizontal scaling factor';
            label{2}='Vertical scaling factor';
            answer=inputdlg(label,'Scale overlay',1,default);
            if isempty(answer)
                return
            end
            [value,count]=sscanf(answer{1},'%g',1);
            if count==1
                data.scale(1)=value;
            end
            [value,count]=sscanf(answer{2},'%g',1);
            if count==1
                data.scale(2)=value;
            end
        case 'shift'
            default{1}=sprintf('%g',data.shift(1));
            default{2}=sprintf('%g',data.shift(2));
            label{1}='Horizontal shift';
            label{2}='Vertical shift';
            answer=inputdlg(label,'Shift overlay',1,default);
            if isempty(answer)
                return
            end
            [value,count]=sscanf(answer{1},'%g',1);
            if count==1
                data.shift(1)=value;
            end
            [value,count]=sscanf(answer{2},'%g',1);
            if count==1
                data.shift(2)=value;
            end
        case 'delete'
            button=questdlg('Remove overlay?','Remove overay');
            if strcmpi(button,'yes')
                delete(hl);
            end
            return;
        case 'color'
            color=uisetcolor;
            if color==0
                return;
            else
                data.color=color;
            end
        case 'width'
            default{1}=sprintf('%g',data.linewidth);
            label{1}=sprintf('%-40s','Line width (points)');
            answer=inputdlg(label,'Line width',1,default);
            if isempty(answer)
                return
            end
            [value,count]=sscanf(answer{1},'%g',1);
            if count==1
                value=max([value 0.1]); % enforce minimum line width
                data.linewidth=max(value);
            end
    end
end

x=data.scale(1)*data.x+data.shift(1);
y=data.scale(2)*data.y+data.shift(2);
set(hl,'XData',x,'YData',y,'UserData',data,...
    'Color',data.color,'LineWidth',data.linewidth);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clone(fig,mode)
toolbar=findobj(fig,'Tag','MinimalFigureToolbar');
toggle=findobj(toolbar,'Tag','clone');
switch mode
    case 'on'
        haxes=ValidAxes(fig);
        if numel(haxes)>1
            data=get(toggle,'UserData');
            set(fig,'WindowButtonUpFcn',@cloneCallback,...
                'Pointer',data.pointer);
        else
            if numel(haxes)==1;
                set(fig,'CurrentObject',haxes);
                cloneCallback(haxes);
            end
            set(toggle,'State','off'); % for user convenience
        end
    case 'off'
        data=get(toolbar,'UserData');
        set(fig,data.figset{:});
end

    function cloneCallback(src,varargin)
        
        % verify normal axes click
        fig=ancestor(src,'figure');
        selection=get(fig,'SelectionType');
        if ~strcmpi(selection,'normal')
            return
        end
        
        target=get(fig,'CurrentObject');
        target=ancestor(target,'axes');
        if ~ishandle(target)
            return
        end
        
        newfig=figure;
        newaxes=copyobj(target,newfig);
        set(newaxes,'OuterPosition',[0 0 1 1]);
        name=sprintf('Cloned plot created %s',datestr(now));
        set(newfig,'Name',name);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=GUIsettings(field)

% input handling
if nargin<1
    field='';
end
if isempty(field)
    field='all';
end
% GUI parameters
persistent param
if isempty(param) % character units
    param.hmargin=1;
    param.vmargin=1;
    param.textheight=1.5;
    param.buttonheight=2;
    %param.controlheight=1.5;
    param.buttonwidth=8; % small button (OK, etc.)
    param.editwidth=15;
    param.labelwidth=4; % small label
    param.checkwidth=10;
    param.fontname='fixed';
    param.textbgcolor=get(0,'DefaultFigureColor');
    param.editcolor=[1 1 1];
end
% output control
field=lower(field);
if strcmp(field,'all')
    func=param;
elseif isfield(param,field)
    func=param.(field);
else
    error('Invalid GUIsettings field');
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DeleteMinimalFigure(varargin)

basetag='MinimalFigure';
Nbase=numel(basetag);

mainfig=findall(0,'Type','figure','Tag',basetag);
fig=findall(0,'Type','figure');
for ii=1:numel(fig)
    if fig(ii)==mainfig
        % hold off delete until end
    else
        tag=get(fig(ii),'Tag');
        if strncmp(tag,basetag,Nbase)
            delete(fig(ii));
        end
    end
end
delete(mainfig);
end