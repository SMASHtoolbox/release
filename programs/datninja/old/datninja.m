% datninja : extract line data from (digitize) an image
%
% The program assists the user in "digitizing a curve", the process of
% converting points in a digital image to a set of (x,y) data points.  To
% do this, the user selects two sets of points in the image.  First, a
% series of reference points are chosen based on known locations in the
% image (e.g., the axes origin).  At least three reference point (not all
% on the same line) must be chosen, and more reference points may be added
% to refine the calibration.  Second, a set of data points--the locations
% of interest--are chosen.  A graphical interface assists this process, and
% the results are saved to a text file.  Data saved by datninja can be
% reloaded into the program, and can be read into MATLAB using the
% datninja_reader function.
%
% Usage:
%  >> datninja(filename); % load image file into the datninja proram
%  >> dataninja; % load program (user will be prompted for a file)

% created November 24, 2008 by Daniel Dolan (Sandia National Labs)
%
% updated December 2, 2008 by Daniel Dolan
%   -switched from WindowKeyPressFcn to KeyPressFcn for backwards
%   compatibility
%   -removed the dock controls
%   -turned off the main figure's integer handle
%   -increased the space available for the axes titles
% updated May 31, 2010 by Daniel Dolan
%   -fixed a logarithmic scaling bug
%   -automatically drop transparency layer (if it exists)
function datninja(imagefile)

% handle input
if nargin<1 
    imagefile='';
end

message{1}='The datninja program is obsolete and will be removed in future toolbox releases';
message{2}='Use the datninja app instead';
warning('%s\n',message{:});

% create GUI
fig=figure('Visible','off','NumberTitle','off',...
    'IntegerHandle','off','DockControls','off',...
    'Name','datninja','Tag','datninja',...
    'Toolbar','none','MenuBar','none',...
    'Units','pixels','Pointer','crosshair',...
    'CloseRequestFcn',@ExitProgram,...
    'KeyPressFcn',@KeyPressFcn);
figcolor=get(fig,'Color');

dummy=repmat('M',[1 40]);
test=uicontrol('Style','pushbutton','Units','pixels',...
    'String',dummy);
extent=get(test,'Extent');
delete(test);
data.charwidth=extent(3)/size(dummy,2);
data.charheight=extent(4)/size(dummy,1);
data.minwidth=80*data.charwidth;
data.minheight=20*data.charheight;
data.gap=5; % pixels
data.margin=data.charheight;
data.imagefile=imagefile;
data.savefile='';

% create menus
hmenu=uimenu('Label','Program');
uimenu(hmenu,'Label','Load image','Tag','LoadImage','Callback',@LoadImage);
uimenu(hmenu,'Label','Save points','Tag','SavePoints',...
    'Callback',@SavePoints,'Separator','on');
hsub=uimenu(hmenu,'Label','Load points');
uimenu(hsub,'Label','Load reference points','Tag','LoadReference',...
    'Callback',@LoadPoints);
uimenu(hsub,'Label','Load data points','Tag','LoadData',...
    'Callback',@LoadPoints);
uimenu(hsub,'Label','Load all points','Tag','LoadAll',...
    'Callback',@LoadPoints);
hsub=uimenu(hmenu,'Label','Remove points');
uimenu(hsub,'Label','Remove reference points','Tag','RemoveReference',...
    'Callback',@RemovePoints);
uimenu(hsub,'Label','Remove data points','Tag','RemoveData',...
    'Callback',@RemovePoints);
uimenu(hsub,'Label','Remove all points','Tag','RemoveAll',...
    'Callback',@RemovePoints);
uimenu(hmenu,'Label','Exit','Tag','ExitProgram',...
    'Callback',@ExitProgram,'Separator','on');

hmenu=uimenu('Label','Tools');
hsub=uimenu(hmenu,'Label','Rotate image');
uimenu(hsub,'Label','Right',...
    'Callback',{@RotateImage,'right'});
uimenu(hsub,'Label','Left',...
    'Callback',{@RotateImage,'left'});
hsub=uimenu(hmenu,'Label','Flip image');
uimenu(hsub,'Label','Vertically',...
    'Callback',{@FlipImage,'vertical'});
uimenu(hsub,'Label','Horizontally',...
    'Callback',{@FlipImage,'horizontal'});
uimenu(hmenu,'Label','Project line',...
    'Callback',@ProjectLine,...
    'Enable','off');

hmenu=uimenu('Label','Options');
hsub=uimenu(hmenu,'Label','Horizontonal scale');
uimenu(hsub,'Label','Linear','Tag','LinearXScale','Callback',@setXScale,...
    'Checked','on');
uimenu(hsub,'Label','Logarithmic','Tag','LogXScale','Callback',@setXScale);
hsub=uimenu(hmenu,'Label','Vertical scale');
uimenu(hsub,'Label','Linear','Tag','LinearYScale','Callback',@setYScale,...
    'Checked','on');
uimenu(hsub,'Label','Logarithmic','Tag','LogYScale','Callback',@setYScale);


hmenu=uimenu('Label','Help');
uimenu(hmenu,'Label','About datninja','Callback',@AboutProgram);
uimenu(hmenu,'Label','Using datninja','Callback',@UsingProgram);

% main axes
hp=uipanel('Parent',fig,'Tag','MainPanel','Units','pixels',...
    'BorderType','none');
ha=axes('Parent',hp,'Tag','MainAxes','Units','pixels',...
    'YDir','reverse');
image('Parent',ha,'Tag','MainImage','CData',ones([480 640 3]),...
    'ButtonDownFcn',{@MoveRectangle,'jump'});
title('Full image');
axis(ha,'image','off');
rectangle('Parent',ha,'LineStyle','--','Tag','ZoomRectangle',...
    'ButtonDownFcn',{@MoveRectangle,'activate'});

% create detail axes
ha=axes('Parent',fig,'Tag','DetailAxes','Units','pixels',...
    'YDir','reverse','XTick',[],'YTick',[],'Box','on');
image('Parent',ha,'Tag','DetailImage','CData',ones([120 120 3]),...
    'ButtonDownFcn',@CreatePoint);
set(ha,'YDir','reverse');
axis(ha,'off');
title('Zoom region');

% create control panel
hp=uipanel('Parent',fig,'Tag','ControlPanel','Units','pixels',...
    'BackgroundColor',figcolor,'BorderType','none');
panelpos=get(hp,'Position');
pos=[data.margin data.margin 0 0];
hc=uicontrol('Parent',hp,'Style','pushbutton','Tag','ZoomIn',...
    'String','zoom in','Callback',@ChangeZoom);
extent=get(hc,'Extent');
pos(3)=8*data.charwidth;
pos(4)=extent(4);
set(hc,'Position',pos);
pos(1)=pos(1)+pos(3)+data.margin;
hc=uicontrol('Parent',hp,'Style','pushbutton','Tag','ZoomOut',...
    'String','zoom out','Callback',@ChangeZoom);
set(hc,'Position',pos);
pos(1)=data.margin;
pos(2)=pos(2)+pos(4)+data.margin;
hc=uicontrol('Parent',hp,'Style','radiobutton','Tag','DataPoints',...
    'String','Select data points','Value',0,'Callback',@PointSelect);
extent=get(hc,'Extent');
pos(3)=20*data.charwidth;
pos(4)=extent(4);
set(hc,'Position',pos);
pos(2)=pos(2)+pos(4)+data.margin;
hc=uicontrol('Parent',hp,'Style','radiobutton','Tag','RefPoints',...
    'String','Select reference points','Value',1,'Callback',@PointSelect);
set(hc,'Position',pos);
panelpos(4)=pos(2)+pos(4)+data.margin;
set(hp,'Position',panelpos);

% store GUI data
data.handles=guihandles(fig);
guidata(fig,data);

% position graphic objects
set(fig,'ResizeFcn',@ResizeWindow);
ResizeWindow(fig,[],data);

% set all uicontrols to have figure's ButtonDownFcn
callback=get(fig,'KeyPressFcn');
clist=findobj(fig,'Type','uicontrol');
set(clist,'KeyPressFcn',callback);

% load image and data (if any)
LoadImage(data.handles.LoadImage);

% make figure visible
movegui(fig,'center');
set(fig,'HandleVisibility','callback');
figure(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% program menu functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadImage(varargin)
src=varargin{1};
data=guidata(src);

filename=data.imagefile;
iscallback=false;
if ishandle(gcbo)
    iscallback=true;
end
if isempty(filename) || iscallback
    filterspec={};
    filterspec(end+1,:)={'*.*','All files (*.*)'};
    filterspec(end+1,:)={'*.jpg;*.JPG;*.jpeg;*.JPEG';'JPEG files (*.jpg)'};
    filterspec(end+1,:)={'*.tif;*.TIF;*.tiff;*.TIFF';'TIFF files (*.tif)'};
    filterspec(end+1,:)={'*.gif;*.GIF;';'GIF files (*.gif)'};
    filterspec(end+1,:)={'*.png;*.PNG;';'PNG files (*.png)'};
    filterspec(end+1,:)={'*.bmp;*.BMP;';'BMP files (*.bmp)'};
    [filename,pathname]=uigetfile(filterspec,'Select image file');
    if isnumeric(filename) % user pressed cancel
        return
    else
        data.imagefile=filename;
        filename=fullfile(pathname,filename);
    end
end

[cdata,map]=imread(filename);
if size(cdata,3)==1
    if isempty(map)
        map=gray(64);
    end
    %cdata=ind2gray(cdata,map);
    colormap(map);
end

switch size(cdata,3)
    case {1,3}
        % do nothing
    case 4
        cdata=cdata(:,:,1:3); % remove transparency layer
    otherwise
        error('ERROR: invalid image format');
end

handles=data.handles;
set(handles.MainImage,'CData',cdata);
axis(handles.MainAxes,'image');
datasize=size(cdata);
bound=min(datasize(1:2))/4;
pos=[0 datasize(1)-bound bound bound];
set(handles.ZoomRectangle,'Position',pos);

set(handles.DetailImage,'CData',cdata);
UpdateDetailAxes(data);

guidata(src,data);

function SavePoints(varargin)
src=varargin{1};
data=guidata(src);
handles=data.handles;

% extract data from figure
h=findobj(handles.MainAxes,'Tag','ReferencePoint');
Nref=numel(h);
[mref,nref,xref,yref]=deal(zeros(1,Nref));
for n=1:Nref
    mref(n)=get(h(n),'XData');
    nref(n)=get(h(n),'YData');
    pointdata=get(h(n),'UserData');
    xref(n)=pointdata.value{1};
    yref(n)=pointdata.value{2};
end

h=findobj(handles.MainAxes,'Tag','DataPoint');
Ndata=numel(h);
[mdata,ndata]=deal(zeros(1,Ndata));
for n=1:Ndata
    mdata(n)=get(h(n),'XData');
    ndata(n)=get(h(n),'YData');
end

% deal with logarithmic scaling
logx=strcmp(get(handles.LogXScale,'Checked'),'on');
if logx
    xref=log10(xref);
end
logy=strcmp(get(handles.LogYScale,'Checked'),'on');
if logy
    yref=log10(yref);
end

% perform linear transformation
z=xref(:)+1i*yref(:);
Q=ones(Nref,3);
Q(:,1)=mref(:);
Q(:,2)=nref(:);
p=Q\z;

Q=ones(Ndata,3);
Q(:,1)=mdata(:);
Q(:,2)=ndata(:);
z=Q*p;
xdata=real(z);
ydata=imag(z);

% undo logarithmic scaling (if present)
if logx
    xdata=10.^(xdata);
    xref=10.^(xref);
end
if logy
    ydata=10.^(ydata);
    yref=10.^(yref);
end

% save points to a file
filterspec={};
filterspec(1,:)={'*.txt;*.TXT'; 'Text files (*.txt)'};
filterspec(2,:)={'*.*' 'All files (*.*)'};
[filename,pathname]=uiputfile(filterspec,...
    'Select file for saving points',data.savefile);
if isnumeric(filename)
    return
end
data.savefile=filename;
filename=fullfile(pathname,filename);

fid=fopen(filename,'wt');
fprintf(fid,'datninja points saved %s \n',datestr(now));
fprintf(fid,'Data format: m n x y \n');
fprintf(fid,'Image file: %s',data.imagefile);
array=transpose([mref(:) nref(:) xref(:) yref(:)]);
fprintf(fid,'\nreference: %.2f %.2f %.6g %.6g',array);
array=transpose([mdata(:) ndata(:) xdata(:) ydata(:)]);
fprintf(fid,'\ndata: %.2f %.2f %.6g %.6g',array);
fclose(fid);

% store changes for later
guidata(src,data);

function LoadPoints(varargin)
src=varargin{1};
data=guidata(src);
handles=data.handles;

% promt user for data file
filterspec={};
filterspec(1,:)={'*.txt;*.TXT'; 'Text files'};
filterspec(2,:)={'*.*' 'All files'};
[filename,pathname]=uigetfile(filterspec,'Select data file');
if isnumeric(filename)
    return
else
    filename=fullfile(pathname,filename);
end

% read points from file
[mref,nref,xref,yref]=deal([]);
[mdata,ndata]=deal([]);
fid=fopen(filename,'rt');
while ~feof(fid)
    temp=fgetl(fid);
    [first,count,err,next]=sscanf(temp,'%s',1);    
    isref=strcmp(first,'reference:');
    isdata=strcmp(first,'data:');
    if isref || isdata        
        temp=temp(next:end);
        [value,count]=sscanf(temp,'%g');
    else
        continue
    end
    if isref && (count>=4)
        mref(end+1)=value(1);
        nref(end+1)=value(2);
        xref(end+1)=value(3);
        yref(end+1)=value(4);
    end
    if isdata && (count>=2)
        mdata(end+1)=value(1);
        ndata(end+1)=value(2);
    end        
end
Nref=numel(mref);
Ndata=numel(mdata);

% insert points into figure (two places each)
tag=get(src,'Tag');
switch tag 
    case 'LoadReference'
        for n=1:Nref
            CreatePoint(handles.DetailImage,'','reference',...
                mref(n),nref(n),xref(n),yref(n));
        end
    case 'LoadData'
        for n=1:Ndata
            CreatePoint(handles.DetailImage,'','data',...
                mdata(n),ndata(n));
        end
    case 'LoadAll'
        for n=1:Nref
            CreatePoint(handles.DetailImage,'','reference',...
                mref(n),nref(n),xref(n),yref(n));
        end        
        for n=1:Ndata
            CreatePoint(handles.DetailImage,'','data',...
                mdata(n),ndata(n));
        end
end

function RemovePoints(varargin)
src=varargin{1};
data=guidata(src);
handles=data.handles;

tag=get(src,'Tag');
switch tag 
    case 'RemoveReference'
        target=findobj(handles.datninja,'Tag','ReferencePoint');
        delete(target);
    case 'RemoveData'
        target=findobj(handles.datninja,'Tag','DataPoint');
        delete(target);
    case 'RemoveAll'
        target=findobj(handles.datninja,'Tag','ReferencePoint');
        delete(target);
        target=findobj(handles.datninja,'Tag','DataPoint');
        delete(target);        
end

function ExitProgram(varargin)
src=varargin{1};
fig=ancestor(src,'figure');
answer=questdlg('Are you sure you want to exit?','Exit dataninja?');
if strcmpi(answer,'yes')
    delete(fig);
else
    figure(fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%
% tools menu functions %
%%%%%%%%%%%%%%%%%%%%%%%%
% set(handles.MainImage,'CData',cdata);
% axis(handles.MainAxes,'image');
% datasize=size(cdata);
% bound=min(datasize(1:2))/4;
% pos=[0 datasize(1)-bound bound bound];
% set(handles.ZoomRectangle,'Position',pos);
% 
% set(handles.DetailImage,'CData',cdata);

function RotateImage(src,~,direction)

fig=ancestor(src,'figure');
data=guidata(fig);
cdata=get(data.handles.MainImage,'CData');
temp=zeros([size(cdata,2) size(cdata,1) size(cdata,3)],class(cdata));
switch direction
    case 'right'                
        for n=1:size(cdata,3)
            temp(:,:,n)=transpose(cdata(:,:,n));
        end          
        temp=temp(:,end:-1:1,:);
    case 'left'
        for n=1:size(cdata,3)
            temp(:,:,n)=transpose(cdata(:,:,n));
        end
        temp=temp(end:-1:1,:,:);        
end
cdata=temp;
set(data.handles.MainImage,'CData',cdata);
set(data.handles.DetailImage,'CData',cdata);

function FlipImage(src,~,direction)

fig=ancestor(src,'figure');
data=guidata(fig);
cdata=get(data.handles.MainImage,'CData');
switch direction
    case 'vertical'
        cdata=cdata(end:-1:1,:,:);
    case 'horizontal'
        cdata=cdata(:,end:-1:1,:);
        
end
set(data.handles.MainImage,'CData',cdata);
set(data.handles.DetailImage,'CData',cdata);

%function ProjectLine(varargin)


%%%%%%%%%%%%%%%%%%%%%%%%%%
% options menu functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function setXScale(varargin)
src=varargin{1};
data=guidata(src);
handles=data.handles;
set([handles.LinearXScale handles.LogXScale],'Checked','off');
set(src,'Checked','on');

function setYScale(varargin)
src=varargin{1};
data=guidata(src);
handles=data.handles;
set([handles.LinearYScale handles.LogYScale],'Checked','off');
set(src,'Checked','on');

%%%%%%%%%%%%%%%%%%%%%%%
% help menu functions %
%%%%%%%%%%%%%%%%%%%%%%%
function AboutProgram(varargin)

message={};
message{end+1}='DATNINJA (DATa NINJA) program';
message{end+1}='version 1.0 (May 2010)';
msgbox(message,'About datninja')

function UsingProgram(varargin)

message={};
message{end+1}='Using the datninja program:';
message{end+1}='1. Load an image into the program.';
message{end+1}='2. Select at least three reference points (not along a line).';
message{end+1}='3. Select the data points of interest.';
message{end+1}='4. Save the points to a file.';
message{end+1}='';
message{end+1}='The full image, with all reference and data points, is shown on the left.';
message{end+1}='The dashed rectangle indicates the zoom region, which is shown on the right. The zoom region can be moved by clicking on the full image, dragging the rectangle, or pressing the direction keys';
message{end+1}='New points are always selected in the zoom region. Right-click on a point to edit or remove it';
%message{end+1}='';
msgbox(message,'Using datninja')

%%%%%%%%%%%%%%%%%%%%%%%
% main axes functions %
%%%%%%%%%%%%%%%%%%%%%%%
function MoveRectangle(varargin)
src=varargin{1};
mode=varargin{3};
data=guidata(src);

handles=data.handles;
fig=ancestor(src,'figure');
switch mode
    case 'jump'
        MousePos=get(handles.MainAxes,'CurrentPoint');
        RectanglePos=get(handles.ZoomRectangle,'Position');
        RectanglePos(1)=MousePos(1,1)-RectanglePos(3)/2;
        RectanglePos(2)=MousePos(1,2)-RectanglePos(4)/2;
        set(handles.ZoomRectangle,'Position',RectanglePos);
        UpdateDetailAxes(data);
    case 'activate'
        store.MousePos=get(handles.MainAxes,'CurrentPoint');
        store.RectanglePos=get(src,'Position');
        store.MotionFcn=get(fig,'WindowButtonMotionFcn');
        set(fig,'WindowButtonMotionFcn',{@MoveRectangle,'move'});
        store.UpFcn=get(fig,'WindowButtonUpFcn');
        set(fig,'WindowButtonUpFcn',{@MoveRectangle,'deactivate'});
        set(src,'UserData',store);
    case 'move'
        store=get(handles.ZoomRectangle,'UserData');
        MousePos=get(handles.MainAxes,'CurrentPoint');
        shift=MousePos-store.MousePos;
        RectanglePos=store.RectanglePos;
        RectanglePos(1)=RectanglePos(1)+shift(1,1);
        RectanglePos(2)=RectanglePos(2)+shift(1,2);
        set(handles.ZoomRectangle,'Position',RectanglePos);
        UpdateDetailAxes(data);
    case 'deactivate'
        store=get(handles.ZoomRectangle,'UserData');
        set(fig,'WindowButtonMotionFcn',store.MotionFcn,...
            'WindowButtonUpFcn',store.UpFcn);
end

function ChangeZoom(varargin)
src=varargin{1};
data=guidata(src);
handles=data.handles;

RectanglePos=get(handles.ZoomRectangle,'Position');
oldwidth=RectanglePos(3);
tag=get(src,'Tag');
switch lower(tag)
    case 'zoomin'
        width=max([oldwidth/2 4]);
    case 'zoomout'
        imsize=size(get(handles.MainImage,'CData'));
        imsize=min(imsize(1:2));
        width=min([2*oldwidth imsize]);      
end
shift=(oldwidth-width)/2;
RectanglePos(1:2)=RectanglePos(1:2)+shift;
RectanglePos(3:4)=width;
set(handles.ZoomRectangle,'Position',RectanglePos);
UpdateDetailAxes(data);
%figure(handles.datninja);

%%%%%%%%%%%%%%%%%%%%%%%%%
% detail axes functions %
%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateDetailAxes(data)
handles=data.handles;
pos=get(handles.ZoomRectangle,'Position');
xb=[pos(1) pos(1)+pos(3)];
yb=[pos(2) pos(2)+pos(4)];
set(handles.DetailAxes,'XLim',xb,'YLIm',yb);

function PointSelect(varargin)

src=varargin{1};
data=guidata(src);
handles=data.handles;

set([handles.RefPoints handles.DataPoints],'Value',0);
set(src,'Value',1);


function CreatePoint(varargin)

src=varargin{1};
data=guidata(src);
handles=data.handles;
if nargin<3
    mode='mouseclick';
else
    mode='manual';
    ptype=varargin{3};    
end

switch mode
    case 'manual'
        x=varargin{4};
        y=varargin{5};
        switch ptype
            case 'reference'
                select_ref=true;
                select_data=false;
                pointdata.value=varargin(6:7);
            case 'data'
                select_ref=false;
                select_data=true;
        end
    case 'mouseclick'
        selection=get(handles.datninja,'SelectionType');
        if ~strcmpi(selection,'normal')
            return
        end        
        select_ref=logical(get(handles.RefPoints,'Value'));
        if select_ref % prompt user for reference values
            value=EnterRefValues();
            if isempty(value)
                return
            else
                pointdata.value=value;
            end
        end
        select_data=logical(get(handles.DataPoints,'Value'));        
        pos=get(handles.DetailAxes,'CurrentPoint');
        x=pos(1,1);
        y=pos(1,2);
end

hpoint(1)=line('Parent',handles.DetailAxes,...
    'XData',x,'YData',y,...
    'Color',[1 0 0],'MarkerSize',10);
hpoint(2)=copyobj(hpoint(1),handles.MainAxes);

hcmenu=uicontextmenu();
uimenu(hcmenu,'Label','Remove this point',...
    'Callback',{@AlterPoint,'RemovePoint',hpoint});
if select_ref    
    set(hpoint,'Marker','+','Tag','ReferencePoint','UserData',pointdata);
    uimenu(hcmenu,'Label','Edit reference values',...
        'Callback',{@AlterPoint,'EditValues',hpoint});
end
if select_data
    set(hpoint,'Marker','x','Tag','DataPoint');
end
set(hpoint,'UIContextMenu',hcmenu);

function AlterPoint(varargin)
%src=varargin{1};
mode=varargin{3};
target=varargin{4};

switch mode
    case 'RemovePoint'
        delete(target);
    case 'EditValues'
        pointdata=get(target(1),'UserData');
        value=pointdata.value;
        value=EnterRefValues(value);
        if isempty(value)
            return
        else
            pointdata.value=value;
            set(target,'UserData',pointdata);
        end       
end

function value=EnterRefValues(oldvalue)

if (nargin<1) || isempty(oldvalue)
    default={'',''};
else % convert numeric values
    default=cell(size(oldvalue));
    for n=1:numel(default)
        default{n}=sprintf('%.6g',oldvalue{n});
    end
end
prompt{1}='Enter horizontal position:';
prompt{2}='Enter vertical position:';
label='Reference point values';
options.Resize='on';
value=inputdlg(prompt,label,1,default,options);
if isempty(value) % user pressed cancel
    return
else
    for n=1:numel(value)
        [value{n},count]=sscanf(value{n},'%g');
        if count~=1
            value{n}=oldvalue{n};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%
% utility functions %
%%%%%%%%%%%%%%%%%%%%%
function ResizeWindow(varargin)

% extract data
fig=varargin{1};
data=guidata(fig);
handles=data.handles;

% enforce minimum figure size
set(fig,'Units','pixels');
figpos=get(fig,'Position');
if figpos(3)< data.minwidth
    figpos(3)=data.minwidth;
end
if figpos(4)<data.minheight
    figpos(2)=figpos(2)-data.minheight+figpos(4);
    figpos(4)=data.minheight;
end
set(fig,'Position',figpos);

pos=get(handles.ControlPanel,'Position');
panelheight=pos(4);
detailheight=figpos(4)-panelheight-3*data.charheight;
detailwidth=detailheight;
x1=figpos(3)-2*data.charheight-detailwidth;

pos=[0 0 x1 figpos(4)];
set(handles.MainPanel,'Position',pos);

pos=[0 0 x1 figpos(4)-2*data.charheight];
set(handles.MainAxes,'Position',pos);

pos(1)=x1+data.charheight;
pos(2)=data.charheight;
pos(3)=detailwidth;
pos(4)=detailwidth;
set(handles.DetailAxes,'Position',pos);

pos(1)=x1;
pos(2)=figpos(4)-panelheight;
pos(3)=figpos(3)-x1;
pos(4)=panelheight;
set(handles.ControlPanel,'Position',pos);

function KeyPressFcn(src,eventdata)
data=guidata(src);
handles=data.handles;

switch eventdata.Key
    case 'leftarrow'
        hshift=-1;
        vshift=0;
    case 'rightarrow'
        hshift=+1;
        vshift=0;
    case 'uparrow'
        hshift=0;
        vshift=+1;
    case 'downarrow'
        hshift=0;
        vshift=-1;
    otherwise
        return
end

xdir=get(handles.MainAxes,'XDir');
if strcmp(xdir,'reverse')
    hshift=-hshift;
end
ydir=get(handles.MainAxes,'YDir');
if strcmp(ydir,'reverse')
    vshift=-vshift;
end

pos=get(handles.ZoomRectangle,'Position');
factor=1/4;
pos(1)=pos(1)+hshift*factor*pos(3);
pos(2)=pos(2)+vshift*factor*pos(4);
set(handles.ZoomRectangle,'Position',pos);
UpdateDetailAxes(data);