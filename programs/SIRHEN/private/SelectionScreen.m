function fig=SelectionScreen(prevfig)

% allocate mising input
if nargin<1
    prevfig=[];
end

% create figure (if necessary)
tag='SIRHEN_SelectionScreen';
fig=findall(0,'Type','figure','Tag',tag);
if isempty(fig)
    name='SIRHEN: Sandia InfraRed HEtrodyne aNalysis';
    fig=createGUI('Tag',tag,'Name',name);
end

% transition to current figure
if ishandle(prevfig)   
    set(prevfig,'Visible','off');
    units=get(prevfig,'Units');
    pos=get(prevfig,'Position');
    data=get(prevfig,'UserData');
    set(fig,'Units',units,'Position',pos,'UserData',data);
    updateGUI(fig);    
end

end

function fig=createGUI(varargin)

screenname='Selection Screen';
% create screen with default analysis options
[fig,button,haxes,hp]=screen('Visible','off',varargin{:});
data=struct(...
    'inputfile','','name','',...
    'reference',[-inf -inf],'experiment',[-inf inf],...
    'ref_frequency',0,'time_shift',0,'frange',[-inf +inf],'fwidth',inf,...
    'flimitpoints',[],'tlimitpoints',[],...
    'duration',nan,'skip',nan,'method','robust','overlap',0,...
    'wavelength',1550e-9,'removeDC',false,'vscale',1,...
    'Nduration',1024,'Nfreq',[1024 1024],'window','hamming',...
    'normalization','global','scaling','log',...
    'clim',[-60 0],'map','jet','invertmap','no',...
    'PDVtype','standard','vlevel',0);
set(fig,'UserData',data);

set(hp,'Title',screenname,'TitlePosition','centertop');
% create menus
hm=uimenu(fig,'Label','Program');
uimenu(hm,'Label','Restore session','Callback',{@RestoreSession,fig});
uimenu(hm,'Label','Start over','Separator','off','Callback',@StartOver);
uimenu(hm,'Label','Exit','Separator','on','Callback','close(gcbf)');

hm=uimenu(fig,'Label','Data');
uimenu(hm,'Label','Load signal','Callback',{@LoadSignal,fig});
uimenu(hm,'Label','Shift signal','Callback',{@ShiftSignal,fig});
uimenu(hm,'Label','Reference region','Callback',{@SelectReference,fig},...
    'Separator','on');
uimenu(hm,'Label','Experiment region','Callback',{@SelectExperiment,fig});
uimenu(hm,'Label','Estimate noise fraction',...
    'Callback',{@EstimateNoise,fig},'Separator','on');
uimenu(hm,'Label','Remove extended baseline',...
    'Callback',{@RemoveBaseline,fig});

hm=uimenu(fig,'Label','Options');
uimenu(hm,'Label','General','Callback',{@GeneralOptions,fig,@updateGUI});
uimenu(hm,'Label','STFT','Callback',{@STFTOptions,fig,@updateGUI});
uimenu(hm,'Label','Display','Callback',{@DisplayOptions,fig,@updateGUI});

hm=uimenu('Label','Help');
uimenu(hm,'Label','Program overview','Callback',@HelpWindow);
uimenu(hm,'Label','About SIRHEN','Callback',@about_SIRHEN);

% customize axes
set(haxes(1),'Tag','SignalAxes');
hc=colorbar('peer',haxes(1));
set(hc,'Visible','off');
xlabel(haxes(1),'Time');
ylabel(haxes(1),'Signal');
line('Parent',haxes(1),'Color','b',...
    'Tag','SignalLine','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(1),'Color','r','LineStyle','--',...
    'Tag','ReferenceBound1a','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(1),'Color','r','LineStyle','--',...
    'Tag','ReferenceBound2a','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(1),'Color','r','LineStyle','-',...
    'Tag','ExperimentBound1a','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(1),'Color','r','LineStyle','-',...
    'Tag','ExperimentBound2a','Visible','off',...
    'XData',[],'YData',[]);

set(haxes(2),'Tag','STFTAxes','YDir','normal');
hc=colorbar('peer',haxes(2));
set(hc,'UIContextMenu',[]);
hc_new=uicontextmenu();
hm_new=uimenu(hc_new,'Label','Display');
set(hm_new,'Callback',{@DisplayOptions,fig,@updateGUI});
set(hc,'UIContextMenu',hc_new); 
ylabel(haxes(2),'Frequency');
xlabel(haxes(2),'Time');
image('Parent',haxes(2),'Tag','STFTImage',...
    'XData',[],'YData',[],'CData',[],'Visible','off');
line('Parent',haxes(2),'Color','r','LineStyle','--',...
    'Tag','ReferenceBound1b','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(2),'Color','r','LineStyle','--',...
    'Tag','ReferenceBound2b','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(2),'Color','r','LineStyle','-',...
    'Tag','ExperimentBound1b','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(2),'Color','r','LineStyle','-',...
    'Tag','ExperimentBound2b','Visible','off',...
    'XData',[],'YData',[]);

linkaxes(haxes,'x');

% customize buttons
set(button(1),'Visible','off');
set(button(2),'Callback',{@NextButton,fig});


end

function LoadSignal(varargin)

fig=varargin{3};
data=get(fig,'UserData');
if isempty(data.inputfile)
    pathname='.';
else
    [pathname,filename]=fileparts(data.inputfile);
end

if (nargin<4) || strcmp(varargin{4},'prompt') % prompt user for file name
    filter={};
    filter{end+1,1}='*.txt;*.TXT;*.dat;*.DAT;*.csv;*.CSV;*.wfm;*.WFM;*.dig;*.DIG;*.h5;*.H5;*.trc;*.TRC';
    filter{end,2}='Supported file types';
    filter{end+1,1}='*.txt;*.TXT;*.dat;*.DAT;*.csv;*.CSV;';
    filter{end,2}='Text files (*.txt, *.dat, *.csv)';
    filter{end+1,1}='*.wfm;*.WFM;';
    filter{end,2}='Tektronix binary files (*.wfm)';
    filter{end+1,1}='*.dig;*.DIG';
    filter{end,2}='NTS binary files (*.dig)';
    filter{end+1,1}='*.h5;*.H5';
    filter{end,2}='Agilent binary files (*.h5)';
    filter{end+1,1}='*.trc;*.TRC';
    filter{end,2}='LeCroy binary files (*.trc)';
    filter{end+1,1}='*.*';
    filter{end,2}='All files (*.*)';
    [filename,pathname]=uigetfile(filter,'Select signal file',pathname);
    if isnumeric(filename)
        return
    end
    data.name=filename;
    data.inputfile=fullfile(pathname,filename);
else
    [pathname,filename,ext]=fileparts(data.inputfile);
    data.name=[filename ext];
end

% load signal from file
[pname,fname,ext]=fileparts(data.name);
try
    switch lower(ext)
        case '.wfm'
            [signal,time]=wfmread(data.inputfile);
        case '.dig'
            [signal,time]=digread(data.inputfile);
        case '.h5'
            %[signal,time]=agilent_h5read(data.inputfile,'gui');
            temp=SMASH.FileAccess.readFile(data.inputfile,'agilent');
            time=temp.Time;
            signal=temp.Signal;
        case '.trc'
            [signal,time]=trcread(data.inputfile);
        otherwise
            temp=ColumnReader(data.inputfile,[],2);
            time=temp(:,1);
            signal=temp(:,2);
    end
catch
    errordlg('Unable to read signal file','File error');
    return
end
drop=isnan(signal) | isinf(signal);
if any(drop)
    message{1}='Signal contains NaN (Not a Number) and/or Inf (infinite) values';
    message{2}='Correction will be attempted, but there may be artifacts';
    h=warndlg(message,'NaN/Inf values found');
    waitfor(h);
    %signal(drop)=(max(signal(~drop))+min(signal(~drop)))/2;    
    index=1:numel(signal);
    index=index(drop);
    for k=1:numel(index)
        if index(k)==1
            value=mean(signal(~drop));
        else
            value=signal(index(k)-1);
        end
        signal(index(k))=value;
    end
end
temp=struct('time',time+data.time_shift,'signal',signal);
set(data.handle{1}.SignalLine,'UserData',temp);

data.update.signal=true;
data.update.fullSTFT=true;
data.update.ref_frequency=true;
data.update.experimentSTFT=true;
data.update.history=true;
data.update.experimentVariable=true;
set(fig,'UserData',data);
updateGUI(fig);

end

function updateGUI(fig)

% extract admin data
data=get(fig,'UserData');
update=data.update;
h=data.handle{1};

% update signal
if update.signal
    update.signal=false;
    temp=get(h.SignalLine,'UserData');
    set(h.SignalLine,'XData',temp.time,'YData',temp.signal,'Visible','on');
    axis(h.SignalAxes,'tight');
    label=sprintf('Signal data for %s',data.name);
    title(h.SignalAxes,label,'Interpreter','none');
end

% update STFT image
if update.fullSTFT   
    update.fullSTFT=false;    
    time=get(h.SignalLine,'XData');
    signal=get(h.SignalLine,'YData');
    options=struct('Nduration',data.Nduration,...
        'Nfreq',data.Nfreq(1),'overlap',data.overlap,'removeDC',data.removeDC,...
        'window',data.window,'normalization',data.normalization);
    [cdata,time,frequency]=stft(signal,time,options);
    set(h.STFTImage,'XData',time,'YData',frequency,...
        'UserData',cdata,'Visible','on');
    if strcmp(data.scaling,'log')
        set(h.STFTImage,'CData',10*log10(cdata));
    else
        set(h.STFTImage,'CData',cdata);
    end        
    axis(h.STFTAxes,'tight');
    label=sprintf('Full STFT image for %s',data.name);
    title(h.STFTAxes,label,'Interpreter','none');
else
    cdata=get(h.STFTImage,'UserData');
end

% update display
if isempty(cdata)
    label='';
elseif strcmp(data.scaling,'log')
    set(h.STFTImage,'CData',10*log10(cdata));
    label='Intensity (dB)';
else
    set(h.STFTImage,'CData',cdata);
    label='Intensity';
end
set(h.STFTImage,'CDataMapping','scaled');
set(h.STFTAxes,'CLim',data.clim);
for n=1:numel(h.Colorbar)
    ylabel(h.Colorbar(n),label);
end
set_colormap(h.STFTAxes,data.map,data.invertmap);

% pass data structure to all figures
data.update=update;
set(fig,'UserData',data);
figure(fig);

end

function ShiftSignal(varargin)

fig=varargin{3};
%h=guihandles(fig);
data=get(fig,'UserData');
h=data.handle{1};

visible=get(h.SignalLine,'Visible');
if strcmp(visible,'off')
    warndlg('No signal data loaded','No data');
    return
end

time_shift_old=data.time_shift;
reference_reset=data.reference-time_shift_old;
experiment_reset=data.experiment-time_shift_old;
temp=get(h.SignalLine,'UserData');
temp.time=temp.time-time_shift_old;
set(h.SignalLine,'UserData',temp);

label={'Shift time:'};
default={time_shift_old};
options.root = fig;
options.location='center';
button = [];
answer=datadlg('Reference duration',label,default,button,options);
value1=sscanf(answer{1},'%g',1);
if isempty(value1)
    return
end
time_shift = value1;

data=get(fig,'UserData');

data.reference=reference_reset + time_shift;
data.experiment=experiment_reset + time_shift;
data.time_shift=time_shift;
temp=get(h.SignalLine,'UserData');
temp.time=temp.time + time_shift;
set(h.SignalLine,'UserData',temp);
set(h.SignalLine,'Xdata',temp.time,'YData',temp.signal,'Visible','on');

if time_shift~=time_shift_old
    data.update.signal=true;
    data.update.fullSTFT=true;
    data.update.ref_frequency=true;
    data.update.experimentSTFT=true;
    data.update.history=true;
end
set(fig,'UserData',data);

updateGUI(fig);

% update signal plot
temp=get(h.SignalLine,'YData');
if isempty(temp)
    return
end
yb=[min(temp) max(temp)];
set(h.ReferenceBound1a,'XData',repmat(data.reference(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ReferenceBound2a,'XData',repmat(data.reference(2),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ExperimentBound1a,'XData',repmat(data.experiment(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ExperimentBound2a,'XData',repmat(data.experiment(2),[1 2]),'YData',yb,...
    'Visible','on');

% update STFT image
temp=get(h.STFTImage,'YData');
yb=[min(temp) max(temp)];
set(h.ReferenceBound1b,'XData',repmat(data.reference(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ReferenceBound2b,'XData',repmat(data.reference(2),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ExperimentBound1b,'XData',repmat(data.experiment(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ExperimentBound2b,'XData',repmat(data.experiment(2),[1 2]),'YData',yb,...
    'Visible','on');

end

function SelectReference(varargin)

fig=varargin{3};
%h=guihandles(fig);
data=get(fig,'UserData');
h=data.handle{1};

visible=get(h.SignalLine,'Visible');
if strcmp(visible,'off')
    warndlg('No signal data loaded','No data');
    return
end

if nargin<4
    label={'Reference begin:','Reference end:'};
    default={data.reference(1), data.reference(2)};
    button(1).label='OK';
    button(1).callback=@defaultOK;
    button(2).label='Cancel';
    button(2).callback=@defaultCancel;
    button(3).label='Use Mouse';
    button(3).callback=@UseMouse;
    options.root = fig;
    options.location='center';
    answer=datadlg('Reference duration',label,default,button,options);
    if isempty(answer)
        return
    elseif isnan(str2double(answer))
        w = waitforbuttonpress;
        pos=get(h.SignalAxes,'CurrentPoint');
        t1 = pos(2,1);
        w = waitforbuttonpress;
        pos=get(h.SignalAxes,'CurrentPoint');
        t2 = pos(2,1);
        tstart=min(t1,t2);
        tend=max(t1,t2);
        default={num2str(tstart),num2str(tend)};
        button = [];
        answer=datadlg('Reference duration',label,default,button,options);
    end
    
    value1=sscanf(answer{1},'%g',1);
    value2=sscanf(answer{2},'%g',2);
    if isempty(value1) || isempty(value2)
        SelectReference([],[],fig);
        return
    end
    data.reference=sort([value1 value2]);
    set(fig,'UserData',data);
end

% update signal plot
temp=get(h.SignalLine,'YData');
if isempty(temp)
    return
end
yb=[min(temp) max(temp)];
set(h.ReferenceBound1a,'XData',repmat(data.reference(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ReferenceBound2a,'XData',repmat(data.reference(2),[1 2]),'YData',yb,...
    'Visible','on');

% update STFT image
temp=get(h.STFTImage,'YData');
yb=[min(temp) max(temp)];
set(h.ReferenceBound1b,'XData',repmat(data.reference(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ReferenceBound2b,'XData',repmat(data.reference(2),[1 2]),'YData',yb,...
    'Visible','on');

data.update.ref_frequency=true;
set(fig,'UserData',data);
figure(fig);

end

function SelectExperiment(varargin)

fig=varargin{3};
%h=guihandles(fig);
data=get(fig,'UserData');
h=data.handle{1};

visible=get(h.SignalLine,'Visible');
if strcmp(visible,'off')
    warndlg('No signal data loaded','No data');
    return
end

if nargin<4
    label={'Experiment begin:','Experiment end:'};
    default={data.experiment(1), data.experiment(2)};
    button(1).label='OK';
    button(1).callback=@defaultOK;
    button(2).label='Cancel';
    button(2).callback=@defaultCancel;
    button(3).label='Use Mouse';
    button(3).callback=@UseMouse;
    options.root = fig;
    options.location='center';
    answer=datadlg('Experiment duration',label,default,button,options);
    if isempty(answer)
        return
    elseif isnan(str2double(answer))
        w = waitforbuttonpress;
        pos=get(h.SignalAxes,'CurrentPoint');
        t1 = pos(2,1);
        w = waitforbuttonpress;
        pos=get(h.SignalAxes,'CurrentPoint');
        t2 = pos(2,1);
        tstart=min(t1,t2);
        tend=max(t1,t2);
        default={num2str(tstart),num2str(tend)};
        button = [];
        answer=datadlg('Experiment duration',label,default,button,options);
    end
    value1=sscanf(answer{1},'%g',1);
    value2=sscanf(answer{2},'%g',2);
    if isempty(value1) || isempty(value2)
        SelectExperiment([],[],fig);
        return
    end
    data.experiment=sort([value1 value2]);
    data.update.experimentSTFT=true;
    data.update.history=true;
    set(fig,'UserData',data);
end

% update signal plot
temp=get(h.SignalLine,'YData');
if isempty(temp)
    return
end
yb=[min(temp) max(temp)];
set(h.ExperimentBound1a,'XData',repmat(data.experiment(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ExperimentBound2a,'XData',repmat(data.experiment(2),[1 2]),'YData',yb,...
    'Visible','on');

% update STFT image
temp=get(h.STFTImage,'YData');
yb=[min(temp) max(temp)];
set(h.ExperimentBound1b,'XData',repmat(data.experiment(1),[1 2]),'YData',yb,...
    'Visible','on');
set(h.ExperimentBound2b,'XData',repmat(data.experiment(2),[1 2]),'YData',yb,...
    'Visible','on');

figure(fig);

end

function EstimateNoise(varargin)

fig=varargin{3};
data=get(fig,'UserData');
if isempty(data.inputfile)
    errordlg('No signal loaded!','No signal');
    return
elseif all(isinf(data.reference))
    errordlg('No reference region defined','No reference region');
    return
end

h=data.handle{1};
time=get(h.SignalLine,'XData');
index=(time>data.reference(1)) & (time<data.reference(2));
if sum(index)==0
    errordlg('No signal in reference region','No signal');
    return
end
signal=get(h.SignalLine,'YData');
noise=estimate_noise(signal(index));
if isnan(noise)
    return
end
noise=[min(noise) max(noise)];
%noise=noise*100; % convert to percent
%if mean(noise)<1
%    format='%.2f';
%elseif mean(noise)<10
%    format='%.1f';   
%else
%    format='%.0f';
%end
%format=['Estimated noise fraction: ' format '%% to ' format '%%'];
%format=['Estimated noise fraction: ' format '%%'];
message{1}=sprintf('Estimated noise fraction: %.2g%% to %.2g%%',100*noise);
msgbox(message,'Noise estimate');

end

function RemoveBaseline(~,~,fig)

hr=msgbox('Select baseline region on the STFT image','Select region','modal');
uiwait(hr);
figure(fig);

target=findobj(fig,'Tag','STFTImage');
haxes=ancestor(target,'axes');
start=[];
hr=[];
set(target,'ButtonDownFcn',@StartBaselineRegion)
    function StartBaselineRegion(varargin)
        start=get(haxes,'CurrentPoint');
        start=start(1,1:2);
        set(target,'ButtonDownFcn',[]);
        set(fig,'WindowButtonUpFcn',@StopBaselineRegion);
        rbbox;
    end
    function StopBaselineRegion(varargin)
        % finish marking region
        stop=get(haxes,'CurrentPoint');
        stop=stop(1,1:2);
        set(fig,'WindowButtonUpFcn',[]);
        if any(start==stop)
            return
        end
        tlim=sort([start(1) stop(1)]);
        flim=sort([start(2) stop(2)]);
        hr=rectangle('Parent',haxes,'Position',[tlim(1) flim(1) diff(tlim) diff(flim)],...
            'EdgeColor','m','Tag','ExtendedBaselineRegion');
        % calculate power spectrum
        hl=findobj(fig,'Tag','SignalLine');
        time=get(hl,'XData');
        signal=get(hl,'YData');
        keep=(time>=tlim(1)) & (time<=tlim(2));
        t=time(keep);
        s=signal(keep);
        data=get(fig,'UserData');
        options.Nduration=1;
        options.Nfreq=data.Nfreq;
        options.window=data.window;        
        [power,~,frequency]=stft(s-mean(s),t,options);
        % estimate f0
        keep=(frequency>=flim(1)) & (frequency<=flim(2));
        frequency=frequency(keep);
        power=power(keep);
        [value,index]=max(power);
        threshold=0.50*value;
        left=index-find(power(index-1:-1:1)<threshold,1,'first');
        right=index+find(power(index+1:end)<threshold,1,'first');
        frequency=frequency(left:right);
        power=power(left:right);
        power=power/trapz(frequency,power);
        f0=trapz(frequency,frequency.*power);
        % estimate phases
        Q=[cos(2*pi*f0*t(:)) sin(2*pi*f0*t(:))];
        param=Q\s(:);
        % remove baseline
        baseline=param(1)*cos(2*pi*f0*time)+param(2)*sin(2*pi*f0*time);
        signal=signal-baseline;
        set(hl,'YData',signal);
        %data.update.signal=true;
        data.update.fullSTFT=true;
        set(fig,'UserData',data);
        updateGUI(fig);
        delete(hr);
    end

end

function NextButton(varargin)

fig=varargin{3};
%h=guihandles(fig);
data=get(fig,'UserData');
h=data.handle{1};

visible=get(h.SignalLine,'Visible');
if strcmp(visible,'off')
    warndlg('No signal data loaded','No data');
    return
end

time=get(h.SignalLine,'XData');
keep=(time>=data.reference(1)) & (time<=data.reference(2));
if sum(keep)==0 % no reference data
    data.ref_frequency=0;
elseif data.update.ref_frequency
    data.update.ref_frequency=false;
    signal=get(h.SignalLine,'YData');
    N=sum(keep);
    N2=max([N/2 1e6]); % 1 ppm frequency bins
    N2=pow2(nextpow2(N2));
    options=struct('Nduration',1,'removeDC',data.removeDC,'Nfreq',N2);
    [intensity,tout,frequency,options]=stft(signal(keep),time(keep),options);
    local=struct('method','centroid');
    result=findpeak(frequency,intensity,local);
    data.ref_frequency=result(1);
end

set(fig,'UserData',data);

AnalysisScreen(fig);

end

function defaultOK(varargin)
fig=gcbf;
uiresume(fig);
data=get(fig,'UserData');
data.current=cell(size(data.edit));
for n=1:numel(data.edit)
    temp=get(data.edit(n),'String');
    %data.current{n}=sscanf(temp,'%s');
    data.current{n}=temp;
end
set(fig,'UserData',data);
end

function defaultCancel(varargin)
fig=gcbf;
uiresume(fig);
data=get(fig,'UserData');
data.current={};
set(fig,'UserData',data);
end

function UseMouse(varargin)
fig=gcbf;
uiresume(fig);
data=get(fig,'UserData');
data.current={NaN};
set(fig,'UserData',data);
end

function RestoreSession(varargin)

message{1}='Load previous session?';
message{2}='Current data and settings will be cleared';
answer=questdlg(message,'Load session?','No');
if strcmpi(answer,'yes')
    % do nothing
else
    return
end

fig=varargin{3};
data=get(fig,'UserData');

% read previous settings from file
[filename,pathname]=uigetfile('*.*','Select export file');
if isnumeric(filename)
    return
end

filename=fullfile(pathname,filename);
[junk,header]=ColumnReader(filename);
for k=1:numel(header)
    sep=find(header{k}=='=',1);
    if isempty(sep)
        continue
    end
    name=sscanf(header{k}(1:sep-1),'%s',1);
    value=header{k}(sep+1:end);
    [result,count,errmsg,next]=sscanf(value,'%g');
    if next>numel(value)
        value=result;
    elseif strcmp(name,'inputfile')
        value=strtrim(value);   
        value=AbsoluteFileName(value,pathname);
    else
        value=sscanf(value,'%s');
        if strcmpi(value,'yes')
            value=true;
        elseif strcmpi(value,'no')
            value=false;
        end
    end
    if isfield(data,name)
        data.(name)=value;
    end
    
end


% update the program
data.update.signal=true;
data.update.fullSTFT=true;
data.update.ref_frequency=true;
data.update.experimentSTFT=true;
data.update.history=true;
set(fig,'UserData',data);
LoadSignal([],[],fig,'silent');
SelectReference([],[],fig,'silent');
SelectExperiment([],[],fig,'silent');

end