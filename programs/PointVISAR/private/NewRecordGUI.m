
%%%%%%%%%%%%%%%%
% main routine %
%%%%%%%%%%%%%%%%
function fig=NewRecordGUI(VISARtype,SignalStorage)

fig=findall(0,'Type','figure','Tag','PointVISAR:NewRecord');
if ishandle(fig) % GUI already exists--clear text fields and reuse
    figure(fig);
    ht=findobj(fig,'Style','edit');
    set(ht,'String','');
    set(fig,'Visible','on');
else % create GUI
    % input check
    if nargin<1
        VISARtype='';
    end
    if nargin<2
        SignalStorage='';
    end
    % default inputs
    if isempty(VISARtype)
        VISARtype='pushpull4';
    end
    if isempty(SignalStorage)
        SignalStorage='single';
    end
    % inteprete VISAR type
    switch VISARtype
        case 'conventional'
            NumSignals=3;
            TypeValue=1;
        case 'pushpull2'
            NumSignals=2;
            TypeValue=2;
        case 'pushpull4'
            NumSignals=4;
            TypeValue=3;
    end
    % interpret signal storage
    switch SignalStorage    
        case 'single'
            NumFiles=1;
            StorageValue=1;
            FileLabel{1}='Data file:';
        case 'separate'
            NumFiles=NumSignals;
            StorageValue=2;
            temp=CreateRecord(VISARtype);
            FileLabel=temp.SignalLabels;
            for ii=1:numel(FileLabel)
                FileLabel{ii}=[FileLabel{ii} ' file:'];
            end
    end
    % GUI spacing parameters (characters)
    dx=5;
    dy=1;
    ControlHeight=2;
    LabelHeight=1;
    EditWidth=80;
    ButtonWidth=10;
    FigWidth=EditWidth+ButtonWidth+3*dx;
    FigHeight=(2+NumFiles)*ControlHeight+(3+NumFiles)*dy+(NumFiles+1)*LabelHeight;
    % create figure
    fig=figure('Visible','off',...
        'MenuBar','none','Toolbar','none',...
        'Tag','PointVISAR:NewRecord','Resize','off',...
        'NumberTitle','off','Name','New VISAR record',...
        'Units','characters','Position',[0 0 FigWidth FigHeight],...
        'CloseRequestFcn',@ExitDialog);
    movegui(fig,'center');
    set(fig,'Visible','on');
    figpos=get(fig,'Position');
    % create VISAR type selection popup
    hlabel=[];
    x0=dx;
    y0=figpos(4)-dy-LabelHeight;
    width=(figpos(3)-4*dx)/2;
    hlabel(end+1)=uicontrol('Style','text',...
        'String','VISAR type (# signals):','HorizontalAlignment','left',...
        'FontName','fixed',...
        'BackgroundColor',get(fig,'Color'),...
        'Units','characters','Position',[x0 y0 width LabelHeight]);
    y0=y0-ControlHeight;
    select(1)=uicontrol('Style','popup',...
        'Tag','TypeSelect',...
        'String',{'Conventional (3)','Standard push-pull (2)','Fast push-pull (4)'},...
        'FontName','fixed',...
        'Value',TypeValue,...
        'Callback',@UpdateDialog,...
        'UserData',{'conventional','pushpull2','pushpull4'},...
        'Units','characters','Position',[x0 y0 width ControlHeight]);
    % create signal storage selection popup
    y0=figpos(4)-dy-LabelHeight;
    x0=dx+width+2*dx;
    hlabel(end+1)=uicontrol('Style','text',...
        'String','Signal storage:','HorizontalAlignment','left',...
        'FontName','fixed',...
        'BackgroundColor',get(fig,'Color'),...
        'Units','characters','Position',[x0 y0 width LabelHeight]);
    y0=y0-ControlHeight;
    select(2)=uicontrol('Style','popup',...
        'Tag','StorageSelect',...
        'String',{'Single file','Separate files'},...
        'FontName','fixed',...
        'Value',StorageValue,...
        'Callback',@UpdateDialog,...
        'UserData',{'single','separate'},...
        'Units','characters','Position',[x0 y0 width ControlHeight]);
    % create file selectors
    hfile=[];
    for ii=1:NumFiles
        x0=dx;
        y0=y0-dy-LabelHeight;
        width=figpos(3)-x0;
        hlabel(end+1)=uicontrol('Style','text',...
            'String',FileLabel{ii},'HorizontalAlignment','left',...
            'FontName','fixed',...
            'BackgroundColor',get(fig,'Color'),...
            'Units','characters','Position',[x0 y0 width LabelHeight]);
        y0=y0-ControlHeight;
        width=figpos(3)-x0-dx-ButtonWidth;
        hedit(ii)=uicontrol('Style','edit',...
            'String','','HorizontalAlignment','right',...
            'FontName','fixed',...
            'BackgroundColor',[1 1 1],...
            'UserData',ii,...
            'Units','characters','Position',[x0 y0 width ControlHeight]);
        x0=x0+width;
        data.label=hlabel(end);
        data.edit=hedit(ii);
        data.extension='txt';
        data.lastdir=pwd;
        hbrowse(ii)=uicontrol('Style','pushbutton',...
            'String','Browse',....
            'FontName','fixed',...
            'UserData',data,'Callback',@BrowseCallback,...
            'Units','characters','Position',[x0 y0 ButtonWidth ControlHeight]);
        hfile=[hfile hedit(ii) hbrowse(ii)];
    end
    % create ok/cancel buttons at the bottom
    y0=dy;
    cancel=uicontrol('Style','pushbutton',...
        'String','Cancel','FontName','fixed',...
        'Tag','cancel','Units','characters');
    extent=get(cancel,'Extent');
    width=1.25*extent(3);
    x0=figpos(3)-dx-width;
    set(cancel,'Position',[x0 y0 width ControlHeight]);
    ok=uicontrol('Style','pushbutton',...
        'String','OK','FontName','fixed',...
        'Tag','ok','Units','characters');
    x0=x0-dx/2-width;
    set(ok,'Position',[x0 y0 width ControlHeight]);
    set([ok cancel],'Callback',@ExitDialog);
    % store handles for later use
    children=[select hfile ok cancel hlabel];
    set(fig,'Children',children(end:-1:1));
    % hide figure from command line users
    set(fig,'HandleVisibility','callback');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% update dialog callback %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateDialog(src,varargin)

fig=ancestor(src,'figure');
htype=findobj(fig,'Tag','TypeSelect');
type=get(htype,'UserData');
value=get(htype,'Value');
type=type{value};

hstorage=findobj(fig,'Tag','StorageSelect');
storage=get(hstorage,'UserData');
value=get(hstorage,'Value');
storage=storage{value};

delete(fig);
NewRecordGUI(type,storage);

%%%%%%%%%%%%%%%%%%%%%%%%
% file browse callback %
%%%%%%%%%%%%%%%%%%%%%%%%
function BrowseCallback(src,varargin)

data=get(src,'UserData');
% preserve previous filterspec
filterspec={...
    '*.*','All files';
    '*.wfm;*.WFM;*.isf;*.ISF','Tektronix binary files';...
    '*.h5;*.H5','Agilent binary files';...
    '*.dig;*.DIG','NTS binary files';...
    '*.taf;*.TAF','Thrifty Array Format files';...
    '*.txt;*.TXT;*.dat;*.DAT;*.csv;*.CSV;*.asc;*.ASC;','Text files'};
%for jj=1:size(filterspec,1)
%    search=strfind(filterspec{jj,1},data.extension);
%    if any(search)
%        temp=filterspec(1,:);
%        filterspec(1,:)=filterspec(jj,:);
%        filterspec(jj,:)=temp;
%        continue
%    end
%end

% generate the correct label
label=get(data.label,'String');
label=['Choose ' label];

old=pwd;
cd(data.lastdir);
[filename,pathname]=getfilename(filterspec,label);
cd(old);

if isnumeric(filename) % user pressed cancel
    return
end

% update the edit box
filename=fullfile(pathname,filename);
set(data.edit,'String',filename);

% update changes for all browse buttons
[pathstr,name,extension]=fileparts(filename);     
button=findobj(gcf,'Style','pushbutton','String','Browse');
for ii=1:numel(button)
    data=get(button(ii),'UserData');
    data.lastdir=pathstr;
    data.extension=extension;
    set(button(ii),'UserData',data);
end

%%%%%%%%%%%%%%%%%
% exit callback %
%%%%%%%%%%%%%%%%%
function ExitDialog(src,varargin)

fig=ancestor(src,'figure');
main=findall(0,'Type','figure','Tag','PointVISAR');
data=get(main,'UserData');
active=ActiveRecord(data);

choice=get(src,'Tag');
if strcmp(choice,'ok') % user chose OK button
    % store the chosen file names
    hedit=findobj(fig,'Style','edit');
    for ii=1:numel(hedit)
        index=get(hedit(ii),'UserData');
        filename=get(hedit(ii),'String');
        if isempty(filename)
            message{1}='Incomplete file input!';
            message{2}='Please specify all files before pressing OK.';
            warndlg(message,'Incomplete input');
            return
        else
            InputFiles{index}=filename;
        end
    end    
    % create the VISAR record
    htype=findobj(fig,'Tag','TypeSelect');
    type=get(htype,'UserData');
    value=get(htype,'Value');
    type=type{value};
    record=CreateRecord(type);
    record.InputFiles=InputFiles;        
    % launch record editing GUI
    if ~isempty(active)
        data{active}.Active=false;
    end
    data{end+1}=record;
    set(main,'UserData',data,'Visible','off');
    record=VisarAnalysis(record,'LoadRecord');
    ReadEditRecordGUI(record); 
else
    answer=questdlg('Cancel record load?','Cancel load?');
    if ~strcmpi(answer,'yes')
        %if ~strcmp(lower(answer),'yes')
        return
    end
end
%delete(fig)
% hide figure (available for later use
set(fig,'Visible','off');