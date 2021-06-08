% PointVISARGUI

% 7/6/2010 : added a bunch of hacks to prevent overlay deletion

%%%%%%%%%%%%%%%%
% main routine %
%%%%%%%%%%%%%%%%
function fig=PointVISARGUI(data)

% input check
if nargin<1
    data=[];
end

fig=findall(0,'Type','figure','Tag','PointVISAR');
hoverlay=[];
if ishandle(fig) % GUI already exists--make it active
    figure(fig);
    set(fig,'Visible','on');
    hselected=findobj(fig,'Type','axes','Tag','SelectedResults');
    hl=get(hselected,'Children');
    for n=1:numel(hl)
        tag=get(hl(n),'Tag');
        if strcmpi(tag,'overlay_line') % hack to preserve overlay lines
            hoverlay(end+1)=hl(n);
            continue
        else
            delete(hl(n));
        end
    end
else % generate the GUI
    % create figure
    fig=MinimalFigure('Tag','PointVISAR','UserData',data,...
        'Name','PointVISAR','NumberTitle','off', ...
        'IntegerHandle','off',...
        'Units','normalized','Position',[0.10 0.10 0.80 0.80],...
        'CloseRequestFcn', @ExitPointVISARGUI);
    % create program menu
    ProgramMenu=uimenu('Label', '&Program', 'Tag', 'ProgramMenu');
    uimenu(ProgramMenu,'Label','Start over',...
        'Tag','StartOver','Callback',@StartOver);
    uimenu(ProgramMenu,'Label','Load configuration',...
        'Tag','LoadConfig','Callback',@ProgramMenuCallback,...
        'Separator','on');
    uimenu(ProgramMenu,'Label','Merge configurations',...
        'Tag','MergeConfigs','Callback',@ProgramMenuCallback);
    uimenu(ProgramMenu,'Label','Save configuration',...
        'Tag','SaveConfig','Callback',@ProgramMenuCallback);
    uimenu(ProgramMenu,'Label','Exit','Separator','on',...
        'Tag','ProgramExit','Callback',@ProgramMenuCallback);
    % create record menu
    RecordMenu=uimenu('Label','&Record','Tag','RecordMenu');
    uimenu(RecordMenu,'Label','&Load new record',...
        'Tag','LoadRecord','Callback',@RecordMenuCallback);
    uimenu(RecordMenu,'Label','&Edit active record',...
        'Tag','EditRecord','Callback',@RecordMenuCallback);
    uimenu(RecordMenu,'Label','Delete active record',...
        'Tag','DeleteRecord','Callback',@RecordMenuCallback);
    % create process menu
    ProcessMenu=uimenu('Label','&Processing','Tag','ProcessMenu');
    uimenu(ProcessMenu,'Label','Add/remove fringes',...
        'Tag','AddRemoveFringe','Callback',@ProcessMenuCallback);
    uimenu(ProcessMenu,'Label','Time shift',...
        'Tag','TimeShift','Callback',@ProcessMenuCallback);
    % create export menu
    ExportMenu = uimenu('Label','&Export','Tag','Export');
    uimenu(ExportMenu, 'Label', 'Active record', ...
        'Tag', 'ExportActive', 'Callback', @ExportMenuCallback);
    uimenu(ExportMenu, 'Label', 'Selected records', ...
        'Tag', 'ExportSelected', 'Callback', @ExportMenuCallback);
    uimenu(ExportMenu, 'Label', 'All records', ...
        'Tag', 'ExportAll', 'Callback', @ExportMenuCallback);
    uimenu(ExportMenu,'Label','Output options',...
        'Tag','OutputOptions','Separator','on',...
        'Callback',@ExportMenuCallback);
    % create help menu
    HelpMenu = uimenu('Label', 'Help', 'Tag', 'Help');
    uimenu(HelpMenu, 'Label', 'Using PointVISAR', 'Tag', 'HelpPointVISAR', ...
        'Enable', 'off','Callback',@HelpMenuCallback);
    uimenu(HelpMenu, 'Label', 'About PointVISAR', 'Tag', 'AboutPointVISAR',...
        'Callback',@HelpMenuCallback);
    % create SplitPanels and fill with axes
    [slider,panel,label,button]=ThumbnailPanels('NumThumbs',3,...
        'PanelLabel',{'Active record','Selected records'},...
        'ButtonLabel',{'choose','choose'});
    set(label,'fontweight','bold');
    set(button(1),'Tag','ActiveRecord','Callback',@ChooseRecord);
    set(button(2),'Tag','SelectedRecords','Callback',@ChooseRecord);
    % determine standard line color sequence
    %color=get(0,'DefaultAxesColorOrder');
    color=DistinguishedLinesRecord(1:2);
    % create signal axes children
    ii=1;
    set(panel(ii),'Tag','Signals');
    ha(ii)=axes('Parent',panel(ii),'Tag','ActiveSignals');
    xlabel('Time');
    ylabel('Signals');
    title('Quadrature signals');
    line('XData',[],'YData',[],'Tag','D1','Color',color(1,:));
    line('XData',[],'YData',[],'Tag','D2','Color',color(2,:));
    % create quadrature axes children
    ii=2;
    ha(ii)=axes('Parent',panel(ii),'Tag','ActiveQuadrature',...
        'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1],...
        'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',[1 1 1]);
    xlabel('D1');
    ylabel('D2');
    title('Quadrature plot');
    line('XData',[],'YData',[],'Tag','data','Color',color(1,:));
    line('XData',[],'YData',[],'Color',[0 0 0],'LineStyle','--',...
        'Tag','EllipsePlot');
        %'Tag','fit');
    % create results axes children (single record)
    ii=3;
    ha(ii)=axes('Parent',panel(ii),'Tag','ActiveResults');
    xlabel('Time');
    hy=ylabel('Velocity');
    set(hy,'UIContextMenu',ResultVariableMenu(hy));
    title('Results');
    line('XData',[],'YData',[],'Tag','data','Color',color(1,:));
    % create results axes (multiple records)
    ha(4)=axes('Parent',panel(4),'Tag','SelectedResults');
    xlabel('Time');
    hy=ylabel('Velocity');
    set(hy,'UIContextMenu',ResultVariableMenu(hy));
    title('Results');
    % general formatting
    set(ha,'Box','on');  
end

% create lines for selected results
hselected=findobj(fig,'Type','axes','Tag','SelectedResults');
N=numel(data);
hl=hoverlay;
for ii=1:N
    temp.Record=ii;
    temp.Label=data{ii}.Label;
    hl(end+1)=fancyline('Parent',hselected,'XData',[],'YData',[],...
        'UserData',temp);
end
set(hselected,'Children',hl);

% hide figure from command line users
set(fig,'HandleVisibility','callback');

UpdateGUI(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update GUI when something changes %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateGUI(data)

fig=findall(0,'Type','figure','Tag','PointVISAR');
set(fig,'UserData',data); 

% render axes for active record
active=ActiveRecord(data);
if isempty(active)
    return
end

% active signal plot
ha=findobj(fig,'Type','axes','Tag','ActiveSignals');
hD1=findobj(ha,'Tag','D1');
hD2=findobj(ha,'Tag','D2');
set(hD1,'XData',data{active}.Time,'YData',data{active}.D{1});
set(hD2,'XData',data{active}.Time,'YData',data{active}.D{2});
message=['Quadrature signals (' data{active}.Label ')'];
title(ha,message,'Interpreter','none');
legend([hD1 hD2],'D1','D2','Location','Best');

% active quadrature plot
ha=findobj(fig,'Type','axes','Tag','ActiveQuadrature');
hdata=findobj(ha,'Tag','data');
set(hdata,'XData',data{active}.D{1},'YData',data{active}.D{2});
message=['Quadrature plot (' data{active}.Label ')'];
title(ha,message,'Interpreter','none');
ellipseFitLine = findobj(fig,'Type','line','Tag', 'EllipsePlot');
if data{active}.EllipseFit       
    % set(ellipseFitLine, 'XData', record.D{1}, 'YData', ...
    %    record.D{2});
    set(ellipseFitLine, 'Visible', 'on');
    EllipsePlot(data{active}.Ellipse, 'overwrite', ha);   
else
    set(ellipseFitLine, 'Visible', 'off');
%    legend(hdata,'data','Location','Best');
end

% active result plot
ha=findobj(fig,'Type','axes','Tag','ActiveResults');
hdata=findobj(ha,'Tag','data');
variable=get(get(ha,'YLabel'),'String');
set(hdata,'XData',data{active}.Time,'YData',data{active}.(variable))
message=['Results (' data{active}.Label ')'];
title(ha,message,'Interpreter','none');

% selected results plot
ha=findobj(fig,'Type','axes','Tag','SelectedResults');
%axes(ha);
hl=findobj(ha,'Type','line','-not','Tag','overlay_line'); % hack to prevent overlay deletion
hl=hl(end:-1:1);
%variable=get(get(ha,'YLabel'),'String');
hmenu=get(get(ha,'YLabel'),'UIContextMenu');
choice=findobj(hmenu,'Checked','on');
variable=get(choice,'Tag');

label={};
hs=[];
N=numel(data);
for ii=1:N   
    if data{ii}.Selected
        set(hl(ii),'Xdata',data{ii}.Time,'Ydata',data{ii}.(variable),...
            'Visible','on','Color',data{ii}.LineColor);
        label{end+1}=data{ii}.Label;
        hs(end+1)=hl(ii);
    else
        set(hl(ii),'Visible','off');
    end
    set(hl(ii),'Tag',data{ii}.Label);
end
legend(hs,label,'Location','Best','Interpreter','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ProgramMenuCallback(src,varargin)

fig=ancestor(src,'figure');
choice = get(src, 'Tag');
switch choice
    case 'LoadConfig'
        message{1}='Load new configuration file?';
        message{2}='Current configuration will be deleted...';
        answer=questdlg(message,'Load config?');
        if strcmpi(answer,'yes')
            data=LoadConfig;
            if isempty(data)
                return
            end
            for n=1:numel(data)
                data{n}.Selected=true;                
                data{n}.Active=false;
            end
            data{end}.Active=true;
            set(fig,'UserData',data);
            PointVISARGUI(data);
        end
    case 'MergeConfigs'
        message{1}='Load and merge configuration files?';
        message{2}='Current configuration will be deleted...';
        answer=questdlg(message,'Merge configs?');
        if strcmpi(answer,'yes')
            data=MergeConfigs;
            if isempty(data)
                return
            end
            for n=1:numel(data)
                data{n}.Selected=true;
                data{n}.Active=false;
            end
            data{end}.Active=true;
            set(fig,'UserData',data);
            PointVISARGUI(data);
        end
    case 'SaveConfig'
        data=get(fig,'UserData');
        SaveConfig(data);
    case 'ProgramExit'
        ExitPointVISARGUI;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecordMenuCallback(src,varargin)   

fig=ancestor(src,'figure');
data=get(fig,'UserData');
active=ActiveRecord(data);

choice = get(src, 'Tag');
switch choice
    case 'LoadRecord'
        NewRecordGUI;
    case 'EditRecord'
        if isempty(active)
            helpdlg('No record to edit','No records');
            return;
        end
        set(fig,'Visible','off');
        record=data{active};
        ReadEditRecordGUI(record);
    case 'DeleteRecord'
        if isempty(active)
            helpdlg('No record to delete','No records');
            return;
        end        
        label=data{active}.Label;       
        message=['Delete ' label '?'];
        answer=questdlg(message,'Delete record?');
        if strcmpi(answer,'yes')
            ii=[1:active-1 active+1:numel(data)];
            data=data(ii);
            if numel(data)>0
                data{1}.Active=true;
            end
            set(fig,'UserData',data);
            PointVISARGUI(data);
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ProcessMenuCallback(src,varargin)

fig=ancestor(src,'figure');
data=get(fig,'UserData');
active=ActiveRecord(data);

if isempty(active)
    helpdlg('No processing allowed until a record is load','No records');
    return;
end       

choice=get(src,'Tag');
switch choice
    case 'AddRemoveFringe'            
        FringeDialog(data);
    case 'TimeShift'
        TimeShiftDialog(data);
    otherwise
        error('ERROR: PointVISARGUI - Unknown tag from Process Menu');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportMenuCallback(src,varargin)

fig=ancestor(src,'figure');
data=get(fig,'UserData');

export=[];
choice=get(src,'Tag');
switch choice
    case 'ExportActive'
        export=ActiveRecord(data);
    case 'ExportSelected'
        for ii=1:numel(data)
            if data{ii}.Selected
                export(end+1)=ii;
            end
        end
    case 'ExportAll'
        export=1:numel(data);
    case 'OutputOptions'
        message{1}='Choose an output style';
        message{2}='      compact : time/velocity only';
        message{3}='      full : all results (fringe shift, contrast, etc.)';
        choice=questdlg(message,'Choose output style','compact','full','compact');
        for ii=1:numel(data)
            data{ii}.OutputFileMode=choice;
        end
        set(fig,'UserData',data);
        return
end

old=pwd;
for ii=1:numel(export)
    dialogText=['Export ''' data{export(ii)}.Label ''' as '];
    filterSpec={'*.out','Output data (space delimited) (*.out)';'*.*','All Files (*.*)'};
    if isempty(data{export(ii)}.OutputFile)
        suggestion=[data{export(ii)}.Label '.out'];
    else
        suggestion=data{export(ii)}.OutputFile{1};
    end  
    [filename,pathname]=putfilename(filterSpec,dialogText,suggestion);
    if isequal(filename, 0) || isequal(pathname, 0) % user cancel
        warndlg('Export canceled by your request','Export canceled');
        return  
    else % store filename and create output file
        data{export(ii)}.OutputFile{1} = fullfile(pathname, filename);
        data{export(ii)}=SaveSignals(data{export(ii)});
        cd(pathname) % future dialogs come up in same directory
    end                        
end
cd(old);
set(fig,'UserData',data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ViewMenuCallback(src,varargin)

choice = get(src, 'Tag');
switch choice
    case 'DefaultView'
        value=1/3;
    case 'ActiveRecord'
        value=1;
    case 'SelectedRecords'
        value=0;
end
ThumbnailPanels('SliderValue', value);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HelpMenuCallback(src,varargin)

choice=get(src,'Tag');
switch choice
    case 'HelpPointVISAR'
        % do something
    case 'AboutPointVISAR'
        AboutPointVISAR;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=ResultVariableMenu(src,varargin)

stype=get(src,'Type');
if strcmp(stype,'uimenu') % execute callback 
    % update check mark
    cmenu=get(src,'Parent');
    children=get(cmenu,'Children');
    set(children,'Checked','off');
    set(src,'Checked','on');

    % change variable
    handle=get(cmenu,'UserData');
    label=get(src,'Label');
    set(handle,'String',label);
    
    fig=ancestor(src,'figure');
    data=get(fig,'UserData');
    %PointVISARGUI(data);
    UpdateGUI(data);
else % create UIContextMenu
    current=get(src,'String');
    func=uicontextmenu('UserData',src);
    hm=[];
    hm(end+1)=uimenu(func,'Label','Velocity','Tag','Velocity',...
        'Callback',@ResultVariableMenu);
    %hm(end+1)=uimenu(func,'Label','Phase','Callback',@ResultVariableMenu);
    hm(end+1)=uimenu(func,'Label','Fringe Shift','Tag','FringeShift',...
        'Callback',@ResultVariableMenu);
    %hm(end+1)=uimenu(func,'Label','BIM','Callback',@ResultVariableMenu);
    hm(end+1)=uimenu(func,'Label','Contrast','Tag','Contrast',...
        'Callback',@ResultVariableMenu);
    for ii=1:numel(hm)
        label=get(hm(ii),'Label');
        if strcmp(label,current)
            set(hm(ii),'Checked','on');
            break
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExitPointVISARGUI(varargin) 

button = questdlg('Are you sure you want to quit?', ...
    'Quitting PointVISAR');
if strcmpi(button,'yes') % exit PointVISAR
    % find all figures
    basetag='PointVISAR';
    Nbase=numel(basetag);
    fig=findall(0,'Type','figure');
    main=findall(0,'Type','figure','Tag','PointVISAR');
    for ii=1:numel(fig)
        if fig(ii)==main
            % hold off delete until end
        else
            tag=get(fig(ii),'Tag');
            if strncmp(tag,basetag,Nbase)
                delete(fig(ii));
            end
        end
    end
    delete(main);
else % return to PointVISAR
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChooseRecord(src,varargin)

% get data from source object
tag=get(src,'Tag');

% get data from GUI
fig=ancestor(src,'figure');
data=get(fig,'UserData');
if isempty(data)
    helpdlg('No records available','No records');
    return;
end

% extract record labels and active/selected record numbers
%width=0;
height=numel(data);
width=zeros([1 height]);
active=ActiveRecord(data);
selected=[];
for ii=1:height
    label{ii}=['Record #' num2str(ii,'%d') ':  ' data{ii}.Label];
    width(ii)=numel(label{ii});
    if data{ii}.Selected
        selected(end+1)=ii;
    end    
end
[width,widest]=max(width);

% create dummy listbox to determine proper sizing
dummy=figure('Visible','off');
h=uicontrol('Parent',dummy,'Style','listbox','String',label{widest});
pos=[0 0 1.50*width height+2];
set(h,'Units','characters','Position',pos,'Units','pixels');
pos=get(h,'Position');
close(dummy);

% listbox settings 
switch tag
    case 'ActiveRecord'
        prompt{1}='Choose active record';
        name='Active record';
        mode='single';
        initial=active;
    case 'SelectedRecords'
        prompt='Choose selected record(s)';
        name='Selected record(s)';
        mode='multiple';
        initial=selected;
    otherwise 
        error('Invalid tag in ChooseRecord item');
end

choice=listdlg(...
    'PromptString',prompt,...
    'Name',name,...
    'SelectionMode',mode,...
    'InitialValue',initial,...
    'ListString',label,...
    'ListSize',pos(3:4));

if isempty(choice) % user pressed cancel
    return
end

switch tag
    case 'ActiveRecord'
        data{active}.Active=false;
        data{choice}.Active=true;
    case 'SelectedRecords'
        for ii=1:numel(selected)
            data{selected(ii)}.Selected=false;
        end
        for ii=1:numel(choice)
            data{choice(ii)}.Selected=true;
        end
end

UpdateGUI(data);
