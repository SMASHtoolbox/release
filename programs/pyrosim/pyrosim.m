% pyrosim: pyrometery measurement simulator
%
% This program calculates the power, photon flux, and signal measured
% by a detector in a pyrometer measurement.  The user may specify the
% object's temperature, emissivity, the limting collection diameter/angle
% of the relay, the relay efficiency, and the detector's response.  A range
% of temperatures may be specified using standard array conventions.
% Constant or variable emissivities, efficiencies, and reponse functions
% may be specified; the latter is achieved by inputting the name of a two
% column text file with the relevant wavelength data.  Non-constant fucntions 
% are assumed to be zero outside the specifed spectral region.
%
% The units for the calculation are as follows.
%    Temperature [K]
%    Wavelength [um]
%    Diameter [mm]
%    Angle [degrees]
%    Response [V/W]
%    Power [W]
%    Photon flux [1/s]
%    Signal [V]
%
% Executing "pyrosim" with no inputs launches the graphical interface.
% Specifying inputs to the function circumvents this interface.
%    >>[phi,phiN,signal]=pyrosim('name1',value1,'name2',value2,...);
% Valid input names are as follows
%      temperature    : array of temperature values
%      emissivity     : emissivity value or file name
%      diameter       : collection diameter (scalar)
%      max_angle      : maximum collection angle (scalar)
%      relay          : relay value or file name
%      response       : detector response value or file name
%      max_wavelength : maximum integration wavelength (scalar)
%      min_wavelength : mininum integration wavelength (scalar)
%      num_wavelength : number of integration points (integer)

% created May 21, 2008 by Daniel Dolan
% updated August 2, 2011 by Daniel Dolan
%%%%%%%%%%%%%%%%%
% main function %
%%%%%%%%%%%%%%%%%
function varargout=pyrosim(varargin)

varargout=cell(nargout,1);
if nargin() == 0 % launch GUI   
    if nargout() > 0
        fprintf('Function output cannot be generated without input arguments \n');
        fprintf('Starting graphical interface instead \n');
    end
    switch SMASH.Graphics.checkGraphics()
        case 'Java'
            if isdeployed
                varargout{1}=1;
            end
            createGUI;
        case 'JavaScript'
            obj=SMASH.RadiometryAnalysis.pyrosim();
            configure(obj);
    end
else     
    if nargout() == 0
        varargout={[]};
    end
    [varargout{:}]=CalculatePower(varargin{:});
end

end

%%%%%%%%%%%%%%%%%%%%%
% support functions %
%%%%%%%%%%%%%%%%%%%%%
function varargout=CalculatePower(varargin)

% default values
temperature=1000; % [K]
emissivity=1; % [-]
diameter=1; % [mm]
max_angle=10; % [deg]
relay=1; % [-]
response=1; % [V/W]
max_wavelength=20; % [um]
min_wavelength=0.1; % [um]
num_wavelength=50e3;

% process input
for n=1:2:nargin
    name=varargin{n};
    if ~ischar(name)
        error('ERROR: non-character name entry');
    end
    try
        value=varargin{n+1};
    catch
        fprintf('Missing value for input ''%s''--trying to continue\n',name);
        continue
    end
    switch lower(name)
        case 'temperature'
            temperature=value;
        case 'emissivity'
            emissivity=value;
        case 'diameter'
            diameter=value;
        case {'angle','max_angle'}
            max_angle=value;
        case 'relay'
            relay=value;
        case 'response'
            response=value;
        case 'max_wavelength'
            max_wavelength=value;
        case 'min_wavelength'
            min_wavelength=value;
        case 'num_wavelength'
            num_wavelength=value;
        otherwise
            fprintf('Unrecogized name ''%s'' will be ignored\n',name);
    end
end
num_points=numel(temperature);
[phi,phiN,signal]=deal(zeros(1,num_points));

% general parameters
c0=2.99792458e8; % vacuum speed of light [m/s]
h=4.135667516E-15; % Planks's constant [eV*s]
kB=8.6173324E-5; % Boltzman's constant [eV/K]
A=2/(h^3*c0^2); % [1/eV^3/m^2/s]
eV=1.602176487E-19; % electron volt [J]
%sigma=(2*kB^4*pi^5)/(15*c0^2*h^3)*eV; % [W/m^2 K^4]
%fprintf('sigma=%.9g\n',sigma);

% define wavelength domain
hc=h*c0;
%hc=SMASH.Reference.PhysicalConstant('hc','spectroscopy')/1e9;
min_energy=hc./(max_wavelength*1e-6); % [eV]
max_energy=hc./(min_wavelength*1e-6);
energy=linspace(min_energy,max_energy,num_wavelength);
wavelength=hc./energy*1e6; % [um]

emissivity=makecurve(emissivity,wavelength);
relay=makecurve(relay,wavelength);
diameter=diameter/1e3; % convert mm to m
relay=(pi*diameter*sind(max_angle)/2)^2*relay;
response=makecurve(response,wavelength);

% perform calculation at each temperature
for n=1:num_points
    kT=kB*temperature(n);
    radiance=zeros(size(energy));
    index=energy<(kT*1e-6);
    radiance(index)=kT*energy(index).^2;
    radiance(~index)=energy(~index).^3./(exp(energy(~index)/kT)-1);
    radiance=A*emissivity.*radiance;
    power=relay.*radiance;
    phi(n)=eV*trapz(energy,power); % collected power [W]
    phiN(n)=trapz(energy,power./energy); % photon flux [1/s]
    signal(n)=eV*trapz(energy,power.*response); % electrical signal [V]
end
varargout{1}=phi;
varargout{2}=phiN;
varargout{3}=signal;

end

function y=makecurve(inp,x)

if ischar(inp) % scan text file
    format='%g%g';
    fid=fopen(inp,'rt');
    Nheader=0;
    success=false;
    while ~feof(fid)
        temp=fgets(fid);
        [A,count]=sscanf(temp,format);
        if count==2
            success=true;
            break
        end
        Nheader=Nheader+1;                    
    end
    if success
        frewind(fid);
        for k=1:Nheader
            fgets(fid);
        end
        data=fscanf(fid,format,[2 inf]);
        data=transpose(data);
        fclose(fid);
    else        
        fclose(fid);
        error('ERROR: unable to read data file %s',inp);
    end
    y=interp1(data(:,1),data(:,2),x,'pchip',0);
elseif numel(inp)==1 % replicate value
    y=repmat(inp,size(x));
else % tabular data (columns)
    y=interp1(inp(:,1),inp(:,2),x,'pchip',0);
end

end

%%%%%%%%%%%%%%%%%
% GUI functions %
%%%%%%%%%%%%%%%%%
function createGUI()

% probe primary monitor size
monpos=get(0,'MonitorPositions');
monpos=monpos(1,:);
monLx=monpos(3)+monpos(1)-1;
monLy=monpos(4)+monpos(2)-1;

Ly=0.75*min([monLx monLy]);
Lx=Ly;
fig=figure('Visible','off','Name','Pyrometry simulator',...    
    'Toolbar','figure','DockControls','off',...
    'Menubar','none','Toolbar','figure',...
    'Units','pixels','Position',[0 0 Lx Lx],...
    'PaperPositionMode','auto',...
    'IntegerHandle','off','NumberTitle','off',...
    'Tag','pyrosim','CloseRequestFcn',@exit_pyrosim);
hb=findall(fig,'Type','uitoolbar');
hc=findall(hb);
for n=1:numel(hc)
    tag=lower(get(hc(n),'Tag'));
    try
        set(hc(n),'Separator','off');
    end
    if strcmpi(tag,'FigureToolBar')
        continue
    end
    if findstr(tag,'exploration')        
        tag=sscanf(tag,'exploration.%s',1);
        switch tag
            case {'zoomin','pan','datacursor'}
                % do nothing
            otherwise
                set(hc(n),'Visible','off');
        end        
    else
        set(hc(n),'Visible','off');
    end
end

data.ymargin=10; % pixels
data.xmargin=data.ymargin;
data.ygap=10; % pixels
filename0=repmat('M',[1 40]);
number0=' +0.0000E+00';

hm=uimenu('Label','Program','Tag','ProgramMenu');
uimenu(hm,'Label','About pyrosim','Tag','AboutProgram')
%uimenu(hm,'Label','Open figure','Tag','OpenFigure','Visible','off');
uimenu(hm,'Label','Save data in workspace','Callback',@saveData,...
    'Separator','on');
    function saveData(varargin)
        commandwindow();
        response=input('Type variable name: ','s');
        if isempty(response)
            return
        end
        data=get(handles.ResultsTable,'Data');
        assignin('base',response,cell2mat(data));
    end
uimenu(hm,'Label','Export data to file','Tag','ExportResults');
uimenu(hm,'Label','Clone plot to new figure','Callback',@clonePlot);
    function clonePlot(varargin)
        new=figure();
        ha=copyobj(handles.ResultPlot,new);
        set(ha,'Units','normalized','OuterPosition',[0 0 1 1]);
    end
uimenu(hm,'Label','Save screenshot (TIF)','Tag','SaveFigure','Visible','off');
uimenu(hm,'Label','Exit','Separator','on','Tag','ExitProgram');

hpanel(1)=uipanel(fig,'Units','pixels','Tag','InputPanel',...
    'BackgroundColor',get(fig,'Color'),'BorderType','none');

pos(1)=data.xmargin;
pos(2)=data.ymargin;
[h,pos]=textlabel(hpanel(1),pos,'Min. wavelength (um): ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,'String',0.1,'Tag','min_wavelength');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,'Max. wavelength (um): ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,'String',20,'Tag','max_wavelength');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,'Integration points: ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,'String',50e3,'Tag','num_wavelength');

pos(1)=data.xmargin;
pos(2)=pos(2)+pos(4)+data.ygap;
[h,pos]=textlabel(hpanel(1),pos,'Detector response (V/W): ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,filename0,...
    'String',1,'Tag','response','HorizontalAlignment','left');
%pos(1)=pos(1)+pos(3);
%[h,pos]=pushbutton(hpanel(1),pos,' select file ');

pos(1)=data.ymargin;
pos(2)=pos(2)+pos(4)+data.ygap;
[h,pos]=textlabel(hpanel(1),pos,'Relay efficiency: ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,filename0,...
    'String',1,'Tag','gamma','HorizontalAlignment','left');
%pos(1)=pos(1)+pos(3);
%[h,pos]=pushbutton(hpanel(1),pos,' select file ');

pos(1)=data.xmargin;
pos(2)=pos(2)+pos(4)+data.ygap;
[h,pos]=textlabel(hpanel(1),pos,'Collection diameter (mm): ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,'String',1,'Tag','maxdiameter');
pos(1)=pos(1)+pos(3);
[h,pos]=textlabel(hpanel(1),pos,'Max. collection angle (deg): ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,number0,'String',10,'Tag','maxangle');

pos(1)=data.ymargin;
pos(2)=pos(2)+pos(4)+data.ygap;
[h,pos]=textlabel(hpanel(1),pos,'Emissivity: ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,filename0,...
    'String',1,'Tag','emissivity','HorizontalAlignment','left');
%pos(1)=pos(1)+pos(3);
%[h,pos]=pushbutton(hpanel(1),pos,' select file ');

pos(1)=data.ymargin;
pos(2)=pos(2)+pos(4)+data.ygap;
[h,pos]=textlabel(hpanel(1),pos,'Temperature (K): ',...
    'HorizontalAlignment','right');
pos(1)=pos(1)+pos(3);
[hedit,pos]=editbox(hpanel(1),pos,repmat('0',[1 40]),...
    'String',1000,'HorizontalAlignment','left','Tag','temperature');
pos(1)=pos(1)+pos(3);
[h,pos]=pushbutton(hpanel(1),pos,' update ','Tag','update');

hc=get(hpanel(1),'Children');
width=0;
height=0;
for k=1:numel(hc)
    pos=get(hc(k),'Position');
    width=max([width pos(1)+pos(3)+data.xmargin]);
    height=max([height pos(2)+pos(4)+data.ymargin]);
end
set(hpanel(1),'Position',[0 0 width height]);

columnname={'Temperature|(K)',' Power |(W)',' Photon flux |(1/s)',' Signal|(V) '};
columnwidth={100 100 100 100};
uitable('Tag','ResultsTable','ColumnName',columnname,'RowName',[],...
    'ColumnWidth',columnwidth,'FontSize',14);

hpanel(2)=uipanel('Units','pixels','Tag','PlotPanel',...
    'BorderType','none');

choice={'Power','Photon flux','Signal'};
popupmenu(hpanel(2),[],choice,...
    'Value',1,'Tag','PlotSelect');

pos=[0 0 1 0.95];
ha=axes('Parent',hpanel(2),'OuterPosition',pos,'Tag','ResultPlot',...
    'Box','on','FontSize',14);
xlabel('Temperature (K)');
line('Parent',ha,'Tag','ResultLine','Color',[0 0 0],'Marker','.');
hc=uicontextmenu();
hsub=uimenu(hc,'Label','Horizontal scaling');
uimenu(hsub,'Label','Linear','Tag','linearx',...
    'Callback',{@AxesContextCallback,ha},'Checked','on');
uimenu(hsub,'Label','Logarithmic','Tag','logx',...
    'Callback',{@AxesContextCallback,ha});
hsub=uimenu(hc,'Label','Vertical scaling');
uimenu(hsub,'Label','Linear','Tag','lineary',...
    'Callback',{@AxesContextCallback,ha},'Checked','on');
uimenu(hsub,'Label','Logarithmic','Tag','logy',...
    'Callback',{@AxesContextCallback,ha});
set(ha,'UIContextMenu',hc);

handles=guihandles(fig);

movegui(fig,'center');
set(fig,'ResizeFcn',{@resizeGUI,handles},'Visible','on',...
    'HandleVisibility','callback');

% set callbacks
set(handles.update,'Callback',{@updateGUI,handles});
set(handles.PlotSelect,'Callback',{@PlotSelect,handles});

h=[handles.AboutProgram handles.SaveFigure handles.ExportResults handles.ExitProgram];
set(h,'Callback',{@ProgramMenuCallback,handles});

%h=[handles.zoom handles.pan handles.datacursor ...
%    handles.linearscale handles.logscale];
%set(h,'Callback',{@PlotMenuCallback,handles});

% analyze the default state
updateGUI(handles.update,[],handles);

end

function resizeGUI(src,eventdata,handles)

% enforce minimum size
figunits=get(src,'Units');
set(src,'Units','pixels');
figpos=get(src,'Position');
pos=get(handles.InputPanel,'Position');
if figpos(3) < pos(3)
    figpos(3)=pos(3);
end
Ly=2*pos(4);
if figpos(4) < Ly
    dy=Ly-figpos(4);
    figpos(2)=figpos(2)-dy;
    figpos(4)=Ly;
end
set(src,'Position',figpos);
set(src,'Units',figunits);

% locate parameter panel
pos=get(handles.InputPanel,'Position');
pos(1)=0;
pos(2)=figpos(4)-pos(4);
set(handles.InputPanel,'Position',pos);
Ly=pos(2);

% size and locate results table
extent=get(handles.ResultsTable,'Extent');
pos(1)=0;
pos(2)=0;
pos(3)=extent(3);
pos(4)=Ly;
set(handles.ResultsTable,'Position',pos);
x0=pos(1)+pos(3);

% size and locate plot panel
pos=get(handles.PlotPanel,'Position');
pos(1)=x0;
pos(2)=0;
pos(3)=figpos(3)-x0;
pos(4)=Ly;
set(handles.PlotPanel,'Position',pos);

% locate plot selection popup
pos=get(handles.PlotSelect,'Position');
pos(1)=0;
pos(2)=Ly-pos(4);
set(handles.PlotSelect,'Position',pos);

end

function updateGUI(src,eventdata,handles)

% read temperature entry
inp=get(handles.temperature,'String');
T=[];
while numel(inp)>0
    [chunk,count,err,next]=sscanf(inp,'%s',1);
    Ncolon=sum(chunk==':');
    if count==0 % no data read
        inp='';
        continue
    elseif Ncolon==0
        val=sscanf(chunk,'%g',1);
    elseif Ncolon==1
        val=sscanf(chunk,'%g%*c%g',2);
        val=val(1):val(2);
    elseif Ncolon==2
        val=sscanf(chunk,'%g%*c%g%*c%g',3);
        val=val(1):val(2):val(3);
    else
        error('ERROR: invalid numeric input: %g',chunk);
    end
    T=[T val];
    inp=inp(next:end);
end
T=validate_input(T,handles.temperature);

% read emissivity entry
inp=get(handles.emissivity,'String');
if exist(inp,'file')
    emissivity=inp;
else
    emissivity=sscanf(inp,'%g',1);
end
emissivity=validate_input(emissivity,handles.emissivity);

% read geometry entries
%collect=[0 0];
inp=get(handles.maxdiameter,'String');
%collect(1)=sscanf(inp,'%g',1);
diameter=sscanf(inp,'%g',1);
diameter=validate_input(diameter,handles.maxdiameter);

inp=get(handles.maxangle,'String');
%collect(2)=sscanf(inp,'%g',1);
max_angle=sscanf(inp,'%g',1);
max_angle=validate_input(max_angle,handles.maxangle);

% read efficiency entry
inp=get(handles.gamma,'String');
if exist(inp,'file')
    gamma=inp;
else
    gamma=sscanf(inp,'%g',1);
end
gamma=validate_input(gamma,handles.gamma);

% read response entry
inp=get(handles.response,'String');
if exist(inp,'file')
    response=inp;
else
    response=sscanf(inp,'%g',1);
end
response=validate_input(response,handles.response);

% read integration entries
inp=get(handles.min_wavelength,'String');
min_wavelength=sscanf(inp,'%g',1);
min_wavelength=validate_input(min_wavelength,handles.min_wavelength);

inp=get(handles.max_wavelength,'String');
max_wavelength=sscanf(inp,'%g',1);
max_wavelength=validate_input(max_wavelength,handles.max_wavelength);

inp=get(handles.num_wavelength,'String');
num_wavelength=round(sscanf(inp,'%g',1));
num_wavelength=validate_input(num_wavelength,handles.num_wavelength);

% run calculation
%[phi,phiN,signal]=CalculatePower(T,emissivity,collect,gamma,response);
[phi,phiN,signal]=CalculatePower(...
    'temperature',T,'emissivity',emissivity,...
    'diameter',diameter,'max_angle',max_angle,...
    'relay',gamma,'response',response,...
    'min_wavelength',min_wavelength,'max_wavelength',max_wavelength,...
    'num_wavelength',num_wavelength);

% update result table
NT=numel(T);
data=cell(NT,4);
for k=1:NT
    data{k,1}=T(k);
    data{k,2}=phi(k);
    data{k,3}=phiN(k);
    data{k,4}=signal(k);
end
set(handles.ResultsTable,'Data',data);
set(handles.ResultsTable,'ColumnFormat',{'short','short','short','short'});

% update result plot
data=struct();
data.T=T;
data.phi=phi;
data.phiN=phiN;
data.signal=signal;
set(handles.ResultLine,'UserData',data);
PlotSelect(src,eventdata,handles);

end

function value=validate_input(value,handle)

data=get(handle,'UserData');
if isempty(value)
    value=data.value;
    set(handle,'String',data.string);
else
    data.value=value;
    data.string=get(handle,'String');
    set(handle,'UserData',data)
end

end

function PlotSelect(src,eventdata,handles)

data=get(handles.ResultLine,'UserData');
x=data.T;

choice=get(handles.PlotSelect,'String');
value=get(handles.PlotSelect,'Value');
choice=choice{value};
switch choice
    case 'Power'
        y=data.phi;
        label='Power (W)';
    case 'Photon flux'
        y=data.phiN;
        label='Photon flux (1/s)';
    case 'Signal'
        y=data.signal;
        label='Signal (V)';
end
set(handles.ResultLine,'XData',x,'YData',y);

ylabel(handles.ResultPlot,label);
axis(handles.ResultPlot,'auto');

end

function ProgramMenuCallback(src,eventdata,handles)

fig=handles.pyrosim;
switch get(src,'Tag')
    case 'AboutProgram'
        msg{1}='Pyrometer simulator (pyrosim)';
        msg{2}='Version 1.1 (August 2011)';
        msg{3}='Daniel Dolan (Sandia National Laboratories)';
        msgbox(msg,'About pyrosim');
    case 'SaveFigure' % feature disabled
%         [fname,pname]=uiputfile({'*.tif;*.TIF'},...
%             'Select screenshot file name','screenshot.tif');
%         if isnumeric(fname) % user pressed cancel
%             return
%         end
%         file=fullfile(pname,fname);
%         [pname,fname,ext]=fileparts(file);
%         %saveas(fig,file,'tiffn');
%         %print(fig,file,'-dtiff','-r300');
%         print(fig,file,'-dpdf');
%         %saveas(fig,file,'pdf');        
%         %filemenufcn(fig,'FileSaveAs');
    case 'ExportResults'
        data=get(handles.ResultsTable,'Data');
        data=cell2mat(data);
        [filename,pathname]=uiputfile('*.*','Select export file');
        if isnumeric(filename)
            return
        end
        filename=fullfile(pathname,filename);       
        fid=fopen(filename,'wt');
        % document settings
        fprintf(fid,'pyrosim results generated %s using...\n',datestr(now));
        emissivity=get(handles.emissivity,'UserData');
        fprintf(fid,'emissivity : %g\n',emissivity.value);
        diameter=get(handles.maxdiameter,'UserData');
        fprintf(fid,'diameter : %g [mm] \n',diameter.value);
        maxangle=get(handles.maxangle,'UserData');
        fprintf(fid,'max angle: %g [deg] \n',maxangle.value);
        relay=get(handles.gamma,'UserData');
        fprintf(fid,'relay: %s\n',relay.string);        
        response=get(handles.response,'UserData');
        fprintf(fid,'response : %s \n',response.string);
        min_wavelength=get(handles.min_wavelength,'UserData');
        max_wavelength=get(handles.max_wavelength,'UserData');
        num_wavelength=get(handles.num_wavelength,'UserData');
        fprintf(fid,'integrating from %g [um] to %g [um] in %d steps\n',...
            min_wavelength.value,max_wavelength.value,num_wavelength.value);
        % data header and table
        label={'Temperature (K)','Power (W)','Photon flux (1/s)','Signal (V)'};
        fprintf(fid,'%18s',label{:});
        fprintf(fid,'\n');
        format='%18.2f%18.6g%18.6e%18.6g\n';
        fprintf(fid,format,transpose(data));
        fclose(fid);        
    case 'ExitProgram'
        exit_pyrosim(fig);      
end

end

function exit_pyrosim(src,varargin)

fig=ancestor(src,'figure');
choice=questdlg('Exit pyrosim?','Exit?','Yes','No','No');
if strcmpi(choice,'yes')
    delete(fig);
end

end

function AxesContextCallback(src,eventdata,target)

tag=get(src,'Tag');
switch tag
    case 'linearx'
        set(target,'XScale','linear');
    case 'logx'
        set(target,'XScale','log');
    case 'lineary'
        set(target,'YScale','linear');
    case 'logy'
        set(target,'YScale','log');
end
axis(target,'auto');
fig=ancestor(target,'figure');
zoom(fig,'reset');

parent=get(src,'Parent');
children=get(parent,'Children');
set(children,'Checked','off');
set(src,'Checked','on');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% custom uicontrol functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,pos]=custom_uicontrol(varargin)

h=uicontrol(varargin{:});
style=get(h,'Style');

% set font
persistent fontname
if isempty(fontname)
    fonts=listfonts;
    fontname='';
    for ii=1:numel(fonts)
        if strcmpi(fonts{ii},'helvetica')
            fontname=fonts{ii};
            break
        end
    end
    if isempty(fontname)
        fontname='fixedwidth';
    end
end
set(h,'FontName',fontname,'FontUnits','points','FontSize',14);

% set units
set(h,'Units','pixels');

% size object based on its contents
pos=get(h,'Position');
extent=get(h,'Extent');
pos(3)=extent(3);
Lymin=1.5*extent(4);
switch style
    case 'popupmenu'
        % do nothing
    otherwise
        pos(4)=Lymin;
end
set(h,'Position',pos);

end

function [h,pos]=textlabel(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

[h,posA]=custom_uicontrol('Parent',parent,'Style','text','String',string);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});

% match the parent color
switch lower(get(parent,'Type'))
    case 'figure'
        bgcolor=get(parent,'Color');
    otherwise
        bgcolor=get(parent,'BackgroundColor');
end
set(h,'BackgroundColor',bgcolor);

% vertically nudge for alignment with other uicontrols
    string=get(h,'String');
    set(h,'String','');
    temppos=get(h,'Position');
    extent=get(h,'Extent');
    temppos(2)=temppos(2)-2*extent(4);
    set(h,'Position',temppos,'String',string);

end

function [h,pos]=editbox(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

[h,posA]=custom_uicontrol('Parent',parent,'Style','edit','String',string);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});

set(h,'BackgroundColor',[1 1 1]);

end

function [h,pos]=pushbutton(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

[h,posA]=custom_uicontrol('Parent',parent,'Style','pushbutton','string',string);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});

end

function [h,pos]=popupmenu(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

extra=repmat('M',[1 5]);
[maxchar,kmax]=max(cellfun(@numel,string));
teststring=[string{kmax} extra];
[h,posA]=custom_uicontrol('Parent',parent,...
    'Style','text','string',teststring);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});
set(h,'Style','popupmenu','String',string);

if ispc
    bgcolor=[1 1 1];
end
if ismac
    switch lower(get(parent,'Type'))
        case 'figure'
            bgcolor=get(parent,'Color');
        otherwise
            bgcolor=get(parent,'BackgroundColor');
    end
end
set(h,'BackgroundColor',bgcolor);

end