function fringenGUI(varargin)

tag='fringen_GUI';
fig=findall(0,'Tag',tag);
if ishandle(fig)
    figure(fig);
    return
end
% create GUI
fig=MinimalFigure(...
    'Tag',tag,...
    'Name','fringen: Fringe generator for VISAR and PDV',...
    'NumberTitle','off','IntegerHandle','off',...
    'Units','normalized','Position',[0.10 0.10 0.80 0.80],...
    'CloseRequestFcn',@ExitProgram);

% create uimenus
hm=uimenu('Label','Program');
uimenu(hm,'Label','Load data','Callback',@LoadData);
uimenu(hm,'Label','Export results','Callback',@ExportResults,...
    'Enable','off');
uimenu(hm,'Label','Start over','Separator','on',...
    'Callback',@StartOver);
uimenu(hm,'Label','Exit','Separator','on',...
    'Callback',@ExitProgram);

hm=uimenu('Label','Interferometer');
hsub=uimenu(hm,'Label','Mode','Tag','InterferometerMode');
uimenu(hsub,'Label','VISAR','Callback',@SelectMode,...
    'Checked','on');
uimenu(hsub,'Label','PDV','Callback',@SelectMode);
uimenu(hm,'Label','Parameters','Callback',@ParamsGUI,'Enable','off');

hm=uimenu('Label','Signal');
hsub=uimenu(hm,'Label','Coupling','Enable','off');
uimenu(hsub,'Label','DC','Callback',@SelectCoupling,...
    'Checked','on','Enable','off');
uimenu(hsub,'Label','AC','Callback',@SelectCoupling,...
    'Enable','off');
hsub=uimenu(hm,'Label','Impulse response','Enable','off');
uimenu(hsub,'Label','Select data file','Callback',@SelectImpulse);
uimenu(hsub,'Label','Remove impulse response','Callback',@RemoveImpulse);
uimenu(hm,'Label','Noise parameters','Callback',@SetNoise,...
    'Enable','off');
uimenu(hm,'Label','Digitizer parameters','Callback',@SetDigitizer,...
    'Enable','off');

hm=uimenu('Label','Help');
uimenu(hm,'Label','Program overview','Callback',@HelpWindow);
uimenu(hm,'Label','About fringen','Callback',@about_fringen);

% create axes
k=1;
ha(k)=subplot(2,2,1);
set(ha(k),'Tag','VelocityPlot',...
    'FontUnits','points','FontSize',12);
xlabel(ha(k),'Time');
ylabel(ha(k),'Velocity');
line('Parent',ha(k),'Tag','VelocityHistory',...
    'Color',[0 0 0],'Visible','off')

k=2;
ha(k)=subplot(2,2,3);
set(ha(k),'Tag','IntensityPlot',...
    'FontUnits','points','FontSize',12);
xlabel(ha(k),'Time');
ylabel(ha(k),'Intensity');
line('Parent',ha(k),'Tag','CoherentHistory',...
    'Color',[0 0 1],'Visible','off');
line('Parent',ha(k),'Tag','EmissionHistory',...
    'Color',[0 0.75 0],'Visible','off');
line('Parent',ha(k),'Tag','ReferenceHistory',...
    'Color',[1 0 0],'Visible','off');

k=3;
ha(k)=subplot(2,2,[2 4]);
set(ha(k),'Tag','SignalPlot',...
    'FontUnits','points','FontSize',12);
xlabel(ha(k),'Time');
ylabel(ha(k),'Signal');
Ncolor=6;
color=zeros(Ncolor,3);
color(1,3)=1; % blue
color(2,2)=0.75; % green
color(3,1)=1; % red
color(4,2:3)=1; % cyan
color(5,[1 3])=1; % magenta
color(6,[1 2])=0.98; % yellow
for n=1:Ncolor
    tag=sprintf('SignalHistory%d',n);
    line('Parent',ha(k),'Tag',tag,'Color',color(n,:),'Visible','off');
end

set(ha,'Box','on');
linkaxes(ha,'x');

set(fig,'HandleVisibility','callback');

%%%%%%%%%%%%%
% callbacks %
%%%%%%%%%%%%%
function LoadData(src,varargin)

% get figure data
fig=ancestor(src,'figure');
data=get(fig,'UserData');
data.inputfile='';
data=import_data(data);
if isempty(data)
    return
end
data=make_signals(data);
data=mangle_signals(data);
set(fig,'UserData',data);
updateGUI(fig);

h=findobj(fig,'Enable','off');
set(h,'Enable','on');

% autoscale all axes
ha=findobj(fig,'Type','axes','-not','Tag','legend');
for n=1:numel(ha)
    %set(ha(n),'XLimMode','auto','YLimMode','auto');
    axis(ha(n),'tight');
    yb=ylim(ha(n));
    Ly=yb(2)-yb(1);
    shift=Ly/20;
    yb=yb+[-shift +shift];
    ylim(ha(n),yb);
    zoom(ha(n),'reset');   
end
linkaxes(ha,'x');

function ExportResults(src,varargin)

% get figure data
fig=ancestor(src,'figure');
data=get(fig,'UserData');

data.outputfile='';
if isfield(data,'signal')
    try
       export_signals(data);
    catch
        % warning dialog
    end
else
    % no signals!
end

function StartOver(varargin)

message{1}='Restart fringen program';
message{2}='All data and settings will be cleared';
answer=questdlg(message,'Restart program?','No');
if strcmpi(answer,'yes')
    fig=findall(0,'Type','figure');
    for n=1:numel(fig)
        tag=get(fig(n),'Tag');
        if strncmp(tag,'fringen',7)
            delete(fig(n));
        end
    end
else
    return
end
fringenGUI();

function ExitProgram(varargin)

answer=questdlg('Exit fringen program?','Exit program?','No');
if strcmpi(answer,'yes')
    fig=findall(0,'Type','figure');
    for n=1:numel(fig)
        tag=get(fig(n),'Tag');
        if strncmp(tag,'fringen',7)
            delete(fig(n));
        end
    end
else
    return
end

function SelectMode(src,varargin)

% access figure data
fig=ancestor(src,'figure');
data=get(fig,'UserData');

% update check mark
label=get(src,'Label');
parent=get(src,'Parent');
children=get(parent,'Children');
set(children,'Checked','off');
set(src,'Checked','on');

if isfield(data,'mode') && strcmpi(data.mode,label)
    return % no change was made
elseif ~isfield(data,'inputfile')
    return % no data loaded
end

data.mode=label;
switch data.mode
    case 'VISAR'
        data.params.phase_shift=[0 180 90 270];
    case 'PDV'   
        data.params.phase_shift=0;
end
data=make_signals(data);
data=mangle_signals(data);
set(fig,'UserData',data);
updateGUI(fig);

function ParamsGUI(src,varargin)

fig=ancestor(src,'figure');
%data=get(fig,'UserData');
%if ~isfield(data,'inputfile') || isempty(data.inputfile)
%    warndlg('Please load a data file before setting parameters',...
%        'No data loaded','modal');
%    return
%end

sub=findobj(fig,'Type','uimenu','Tag','InterferometerMode');
choice=findobj(sub,'Checked','on');
switch get(choice,'Label')
    case 'VISAR'
        VISARparamsGUI(fig);
    case 'PDV'
        PDVparamsGUI(fig);
end

function SelectCoupling(src,varargin)

% access figure data
fig=ancestor(src,'figure');
data=get(fig,'UserData');

% update check mark
label=get(src,'Label');
parent=get(src,'Parent');
children=get(parent,'Children');
set(children,'Checked','off');
set(src,'Checked','on');

% apply new settings if change was made
if isfield(data.params,'coupling') && strcmpi(data.params.coupling,label)
    return % no change was made
elseif ~isfield(data,'inputfile');
    return % no data loaded
end
data.params.coupling=label;
data=make_signals(data);
data=mangle_signals(data);
set(fig,'UserData',data);    
updateGUI(fig);

function SelectImpulse(src,varargin)

fig=ancestor(src,'figure');
data=get(fig,'UserData');

if ~isfield(data.params,'impulse_response')
    data.params.impulse_response='';
    default=pwd;
else
    default=data.params.impulse_response;
end
[filename,pathname]=uigetfile('*.*','Select impulse response file',default);
if isnumeric(filename)
    return
end
data.params.impulse_response=fullfile(pathname,filename);
data=make_signals(data);
data=mangle_signals(data);
set(fig,'UserData',data);
updateGUI(fig);

function RemoveImpulse(src,varargin)

fig=ancestor(src,'figure');
data=get(fig,'UserData');
data.params.impulse_response='';
data=make_signals(data);
data=mangle_signals(data);
set(fig,'UserData',data);
updateGUI(fig);

function SetNoise(src,varargin)

fig=ancestor(src,'figure');
data=get(fig,'UserData');
%if ~isfield(data,'inputfile') || isempty(data.inputfile)
%    warndlg('Please load a data file before setting parameters',...
%        'No data loaded','modal');
%    return
%end

if ~isfield(data.params,'noise_frac') || isempty(data.params.noise_frac)
    data.params.noise_frac=0;
end

label{1}='Noise fraction:';
default{1}=sprintf('%.6g',data.params.noise_frac);

label{2}='Noise seed:';
default{2}=sprintf('%d',data.params.noise_seed);

options.Interpreter='tex';
answer=inputdlg(label,'Noise parameters',[1 40],default,options);
if isempty(answer)
    return
end
data.params.noise_frac=sscanf(answer{1},'%g',1);
data.params.noise_seed=sscanf(answer{2},'%d',1);
data=make_signals(data);
data=mangle_signals(data);
set(fig,'UserData',data);
updateGUI(fig);

function SetDigitizer(src,varargin)

fig=ancestor(src,'figure');
data=get(fig,'UserData');
%if ~isfield(data,'inputfile') || isempty(data.inputfile)
%    warndlg('Please load a data file before setting parameters',...
%        'No data loaded','modal');
%    return
%end

if ~isfield(data.params,'bit_range') || isempty(data.params.bit_range)
    data.params.bit_range=8;
end

label{1}='Bit range:';
default{1}=sprintf('%.6g',data.params.bit_range);
answer=inputdlg(label,'Digitizer range',[1 40],default);
if isempty(answer)
    return
end
data.params.bit_range=sscanf(answer{1},'%g',1);
data=make_signals(data);
data=mangle_signals(data);
set(fig,'UserData',data);
updateGUI(fig);