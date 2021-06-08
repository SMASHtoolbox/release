function fig=AnalysisScreen(prevfig)

% allocate mising input
if nargin<1
    prevfig=[];
end

% create figure (if necessary)
tag='SIRHEN_AnalysisScreen';
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

screenname='Analysis Screen';
[fig,button,haxes,hp]=screen('Visible','off',varargin{:});
data=struct();
set(fig,'UserData',data);
set(hp,'Title',screenname,'TitlePosition','centertop');

% create menus
hm=uimenu(fig,'Label','Program');
% uimenu(hm,'Label','Restore session','Enable','off');
uimenu(hm,'Label','Start over','Callback',@StartOver);
uimenu(hm,'Label','Exit','Separator','on','Callback','close(gcbf)');

hm=uimenu(fig,'Label','Data');
uimenu(hm,'Label','Calculate history','Callback',{@CalculateHistory,fig});
%uimenu(hm,'Label','Generate BIM','Enable','off');
uimenu(hm,'Label','Define frequency limits','Callback',{@SetFrequencyLimits,fig});
uimenu(hm,'Label','Estimate uncertainty','Callback',{@EstimateUncertainty,fig},...
    'Separator','on');
uimenu(hm,'Label','Export history','Callback',{@ExportHistory,fig},...
       'Separator','on');
uimenu(hm,'Label','Export STFT image','Callback',{@ExportSTFT,fig});


hm=uimenu(fig,'Label','Options');
uimenu(hm,'Label','General','Callback',{@GeneralOptions,fig,@updateGUI});
uimenu(hm,'Label','STFT','Callback',{@STFTOptions,fig,@updateGUI});
uimenu(hm,'Label','Display','Callback',{@DisplayOptions,fig,@updateGUI});

hm=uimenu('Label','Help');
uimenu(hm,'Label','Program overview','Callback',@HelpWindow);
uimenu(hm,'Label','About SIRHEN','Callback',@about_SIRHEN);

% customize axes
set(haxes(1),'Tag','STFTAxes','YDir','normal');
hc=colorbar('peer',haxes(1));
set(hc,'UIContextMenu',[]);
hc_new=uicontextmenu();
hm_new=uimenu(hc_new,'Label','Display');
set(hm_new,'Callback',{@DisplayOptions,fig,@updateGUI});
set(hc,'UIContextMenu',hc_new); 
hc=uicontextmenu();
uimenu(hc,'Label','Absolute frequency','Callback',{@ChangeVariable,fig});
uimenu(hc,'Label','Relative frequency','Callback',{@ChangeVariable,fig});
uimenu(hc,'Label','Velocity','Callback',{@ChangeVariable,fig},'Checked','on');
ylabel(haxes(1),'Velocity','UIContextMenu',hc);
xlabel(haxes(1),'Time');
image('Parent',haxes(1),'Tag','STFTImage','Visible','off');
line('Parent',haxes(1),'Color','w','LineStyle','none','Marker','X',...
    'Tag','BoundPoints','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(1),'Color','w','LineStyle','-',...
    'Tag','BoundCenterLine','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(1),'Color','w','LineStyle','--',...
    'Tag','BoundMaxLine','Visible','off',...
    'XData',[],'YData',[]);
line('Parent',haxes(1),'Color','w','LineStyle','--',...
    'Tag','BoundMinLine','Visible','off',...
    'XData',[],'YData',[]);

set(haxes(2),'Tag','HistoryAxes');
hc=colorbar('peer',haxes(2));
set(hc,'Visible','off');
hc=uicontextmenu();
uimenu(hc,'Label','Absolute frequency','Callback',{@ChangeVariable,fig});
uimenu(hc,'Label','Relative frequency','Callback',{@ChangeVariable,fig});
uimenu(hc,'Label','Velocity','Callback',{@ChangeVariable,fig},'Checked','on');
ylabel(haxes(2),'Velocity','UIContextMenu',hc);
xlabel(haxes(2),'Time');
line('Parent',haxes(2),'Color','b',...
    'Tag','HistoryLine','Visible','off');

linkaxes(haxes,'x');

% customize buttons
set(button(2),'Visible','off');
set(button(1),'Callback',{@PreviousButton,fig});

end

function CalculateHistory(varargin)

fig=varargin{3};
data=get(fig,'UserData');

% prompt user for analysis parameters
label={'Analysis duration:','Skip interval:','Mininum # frequency points:',...
    'Peak location method:'};
default={data.duration(end), data.skip(end), data.Nfreq(end), data.method};
button=[];
options.root=fig;
options.location='center';
answer=datadlg_calhist('History parameters',label,default,options);
if isempty(answer)
    return
end
duration=sscanf(answer{1},'%g',1);
skip=sscanf(answer{2},'%g',1);
Nfreq=round(sscanf(answer{3},'%g',1));
method=sscanf(answer{4},'%s',1);

if isempty(duration) || isempty(skip) || isempty(Nfreq) || isempty(method)
    CalculateHistory([],[],fig);
    return    
end

if(duration>abs(data.experiment(1)-data.experiment(2)))
    message{1}='Analysis duration CANNOT';
    message{2}='be larger than experiment duration';
    answer = questdlg(message,'Input Error','OK','OK');
    switch answer
        case 'OK'
            CalculateHistory([],[],fig);
            return
    end
end

if(skip>abs(data.experiment(1)-data.experiment(2)))
    message{1}='Skip interval CANNOT';
    message{2}='be larger than experiment duration';
    answer = questdlg(message,'Input Error','OK','OK');
    switch answer
        case 'OK'
            CalculateHistory([],[],fig);
            return
    end
end

if((duration/skip)>1000)
     message{1}='Very LARGE calculation';
     message{2}='may take awhile or freeze program';
     answer=questdlg(message,'Warning','Continue','Cancel','Cancel');
     switch answer
         case 'Cancel'
             CalculateHistory([],[],fig);
             return
     end
end

change=(data.duration~=duration)|(data.skip~=skip)...
    |(data.Nfreq(end)~=Nfreq) | ~strcmp(data.method,method);
if change
    data.update.history=true;
    data.duration(2)=duration;
    data.skip(2)=skip;
    data.Nfreq(2)=Nfreq;
    data.method=method;
    set(fig,'UserData',data);
    updateGUI(fig);
end

end

function SetFrequencyLimits(varargin)

fig=varargin{3};
data=get(fig,'UserData');
h=data.handle{2};

hc=findobj(fig,'Type','uimenu','Label','Absolute frequency');
ChangeVariable(hc(1),[],fig);
ChangeVariable(hc(2),[],fig);
image=get(h.STFTImage,'UserData');

time=get(h.HistoryLine,'XData')';
fimagemax = max(image.yvar);
tlength = length(time);
options.root = fig;
options.location='center';
set([h.BoundPoints h.BoundCenterLine],'Visible','off');
set([h.BoundMinLine h.BoundMaxLine],'Visible','off');

user_response = questdlg('Type of frequency limit?','Frequency limit type',...
                          'Static','Dynamic','Static');
switch user_response
    case {'Static'}
        label={'Mininum abs. frequency:','Maximum abs. frequency:'};
        default={data.frange(1), data.frange(2)};
        button(1).label='OK';
        button(1).callback=@defaultOK;
        button(2).label='Cancel';
        button(2).callback=@defaultCancel;
        button(3).label='Use Mouse';
        button(3).callback=@UseMouse;
        options.root = fig;
        options.location='center';
        answer=datadlg('Static frequency limits',label,default,button,options);      
        if isempty(answer)
            return
        elseif isnan(str2double(answer))
            w = waitforbuttonpress;
            pos=get(h.STFTAxes,'CurrentPoint');
            f1 = pos(2,2);
            w = waitforbuttonpress;
            pos=get(h.STFTAxes,'CurrentPoint');
            f2 = pos(2,2);
            fmin=min(f1,f2);
            fmax=max(f1,f2);
            default={num2str(fmin,'%10.5e\n'),num2str(fmax,'%10.5e\n')};
            button = [];
            answer=datadlg('Frequency limits',label,default,button,options);
        end
        data.frange(1)=sscanf(answer{1},'%g',1);
        data.frange(2)=sscanf(answer{2},'%g',1);
        data.frange=sort(data.frange);
        data.fwidth=data.frange(2)-data.frange(1);
        fcenter = (data.frange(2)+data.frange(1))/2;
        if isempty(data.frange(1)) || isempty(data.frange(2))
            SetFrequencyLimit([],[],fig);
            return
        end 
        boundcenterline = fcenter*ones(tlength,1);
        boundminline = max(data.frange(1)*ones(tlength,1),0);
        boundmaxline = min(data.frange(2)*ones(tlength,1),fimagemax);
        data.flimitpoints = [fcenter fcenter];
        data.tlimitpoints = [time(1) time(tlength)];                
    case {'Dynamic'}        
        if numel(data.flimitpoints)<=2
            prompt{1}='Define new bounding curve';
            prompt{2}='   -Left click image for new curve points';
            prompt{3}='   -Right click when you are done';
            box=msgbox(prompt,'New curve','help');
            waitfor(box)
            answer='New';
        else
            prompt{1}='Define new bounding curve or use existing curve?';
            prompt{2}='   -Left click image for new curve points';
            prompt{3}='   -Right click when you are done';
            answer=questdlg(prompt,'New or existing curve','New','Existing','New');
            if isempty(answer)
                return
            end
        end
        if strcmp(answer,'New')
            xcenter=[];
            ycenter=[];
            pointer=get(fig,'Pointer');
            set(fig,'Pointer','crosshair');           
            figure(fig);
            while true
                w=waitforbuttonpress;                
                if w==1
                    continue
                end
                selection=get(fig,'SelectionType');
                if ~strcmp(selection,'normal')
                    break
                end
                pos=get(h.STFTAxes,'CurrentPoint');
                if any(pos(2,1)==xcenter)
                    continue % avoid points that give interp1 heartache
                end
                xcenter(end+1)=pos(2,1);
                ycenter(end+1)=pos(2,2);               
                set(h.BoundPoints,'Visible','on',...
                    'XData',xcenter,'YData',ycenter);                
            end
            set(fig,'Pointer',pointer);
            center=[xcenter(:) ycenter(:)];
            center = sortrows(center);
            data.tlimitpoints = center(:,1);
            data.flimitpoints = center(:,2);
        end
        label={'Frequency width'};
        if isempty(data.fwidth)
            data.fwidth=fimagemax/10; % use 10% of frequency range
        end       
        default={data.fwidth};
        button(1).label='OK';
        button(1).callback=@defaultOK;
        button(2).label='Cancel';
        button(2).callback=@defaultCancel;
        answer=datadlg('Dynamic frequency limits',label,default,button,options);
        if isempty(answer)
            set(h.BoundPoints,'Visible','off');
            return
        else
            data.fwidth = sscanf(answer{1},'%g',1);           
        end
    otherwise
        return
end

boundcenterline = interp1(data.tlimitpoints,data.flimitpoints,time,'linear','extrap');
boundminline = max(boundcenterline - data.fwidth/2,0);
boundmaxline = min(boundcenterline + data.fwidth/2,fimagemax);
set(h.BoundCenterLine,'Visible','on',...
                    'XData',time,'YData',boundcenterline);
set(h.BoundMinLine,'Visible','on',...
                    'XData',time,'YData',boundminline)  
set(h.BoundMaxLine,'Visible','on',...
                    'XData',time,'YData',boundmaxline)          
user_response = questdlg('Apply frequency limits to history?','Frequency limits',...
                          'Apply','Cancel','Apply');
switch user_response
    case {'Apply'}
        data.update.history=true;       
        set(fig,'UserData',data);
        updateGUI(fig);
    %case {'Cancel'}
    otherwise
        set([h.BoundPoints h.BoundCenterLine h.BoundMinLine h.BoundMaxLine],...
            'Visible','off');
        return
end

end

function EstimateUncertainty(varargin)

fig=varargin{3};
data=get(fig,'UserData');
if all(isinf(data.reference))
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
    message={};
    message{end+1}='Insufficient reference signal present for noise estimate!';
    message{end+1}='Expand reference region and try again.';
    warndlg(message,'Not enough ref. signal');
    return
end
%noise=sort(noise);
noise=[min(noise) max(noise)];

tsignal=get(h.SignalLine,'XData');
T=(tsignal(end)-tsignal(1))/(numel(tsignal)-1);
fs=1/T;
message={};
message{end+1}='';
message{end+1}=sprintf('Estimated noise fraction: %.2g%% to %.2g%%',100*noise);
message{end+1}=sprintf('Analysis duration: %.2g',data.duration(end));
message{end+1}=sprintf('Sampling rate: %.2g',fs);
message{end+1}='';
message{end+1}=sprintf('Window function: %s',data.window);
scale0=0.58;
switch data.window
    case 'boxcar'
        scale=scale0;
    case 'hamming'
        scale=0.37;        
    case 'hann'
        scale=0.34;
    case 'blackman'
        scale=0.30; % this is a guess        
end
tau=data.duration(end)*(scale/scale0);
Df=sqrt(6/fs/tau^3)*noise/pi;
Dv=Df*(data.wavelength/2);
message{end+1}=sprintf('   Frequency uncertainty: %.2g to %.2g',Df);
message{end+1}=sprintf('   Velocity uncertainty: %.2g to %.2g',Dv);
message{end+1}=sprintf('   10-90%% rise time: %.2g',data.duration(end)*scale);
message{end+1}='';
msgbox(message,'Uncertainy estimate');
end

function ExportHistory(varargin)

fig=varargin{3};
data=get(fig,'UserData');
h=data.handle{2};

time=get(h.HistoryLine,'XData');
velocity=get(h.HistoryLine,'YData');
results=get(h.HistoryLine,'UserData');
intensity=results(2,:);

temp=zeros(numel(time),3);
temp(:,1)=time;
temp(:,2)=velocity;
%temp(:,3)=intensity;
temp(:,3)=intensity/max(intensity);

filespec={'*.*','All files'};
[filename,pathname]=uiputfile(filespec,'Select output file');
if isnumeric(filename)
    return
end
data.outputfile=fullfile(pathname,filename);

fid=fopen(data.outputfile,'wt');

fprintf(fid,'SIRHEN signal export (%s)\n',datestr(now));

data.removeDC=logical(data.removeDC);
name=fieldnames(data);
value=struct2cell(data);
for k=1:numel(name)
    if strcmp(name{k},'handle') || strcmp(name{k},'update')
        continue % skip adminstrative fields
    elseif strcmp(name{k},'PDVtype')
        continue % skip unused fields
    elseif strcmp(name{k},'name') || strcmp(name{k},'outputfile')
        continue % skip redundant information
    end
    fprintf(fid,'%14s=',name{k});
    if strcmp(name{k},'inputfile')
        % convert to relative file name
        value{k}=RelativeFileName(value{k},pathname);
        format='%s';        
    elseif ischar(value{k})
        format='%15s';
    elseif islogical(value{k})
        if value{k}
            value{k}='yes';
        else
            value{k}='no';
        end
        format='%15s';
    elseif isnumeric(value{k})
        if any((value{k}~=floor(value{k})) | isinf(value{k}))
                format='%+15.5e';           
        else
            format='%15d';
        end 
    end 
    fprintf(fid,format,value{k});
    fprintf(fid,'\n');
end

label=get(get(h.HistoryLine,'Parent'),'Ylabel');
label=get(label,'String');
switch label
    case 'Velocity'
        % do nothing
    case 'Relative frequency'
        label='Rel. freq.';
    case 'Absolute frequency'
        label='Abs. freq.';
end
fprintf(fid,'%15s%15s%15s','Time',label,'Intensity');
fprintf(fid,'\n');
format=repmat('%+15.5e',[1 3]);
format=[format '\n'];
fprintf(fid,format,transpose(temp));

fclose(fid);

end

function ExportSTFT(varargin)

fig=varargin{3};
data=get(fig,'UserData');
h=data.handle{2};
xdata=get(h.STFTImage,'XData')';
ydata=get(h.STFTImage,'YData')';
zdata=get(h.STFTImage,'CData');

filespec={'*.*','All files'};
[filename,pathname]=uiputfile(filespec,'Select output file');
if isnumeric(filename)
    return
end
data.outputfile=fullfile(pathname,filename);

% generate column labels
ha=data.handle{2}.STFTAxes;
ht=get(ha,'XLabel');
label{1}=get(ht,'String');
ht=get(ha,'YLabel');
label{2}=get(ht,'String');
ha=data.handle{2}.Colorbar(1);
ht=get(ha,'YLabel');
label{3}=get(ht,'String');
header=sprintf('%20s',label{:});

% write data to a (x,y,z) file
[X,Y]=meshgrid(xdata,ydata);
temp=[X(:) Y(:) zdata(:)];
fid=fopen(data.outputfile,'wt');
fprintf(fid,'%s\n',header);
fprintf(fid,'%+20.5e%+20.5e%+20.5f\n',transpose(temp));
fclose(fid);

set(fig,'UserData',data);

end

function updateGUI(fig)

% extract admin data
data=get(fig,'UserData');
update=data.update;
h=data.handle{2};
hsrc=data.handle{1};

% update STFT image
if update.experimentSTFT
    time=get(hsrc.SignalLine,'XData');
    signal=get(hsrc.SignalLine,'YData');
    keep=(time>=data.experiment(1)) & (time<=data.experiment(2));
    options=struct('Nduration',data.Nduration,'overlap',data.overlap,...
        'Nfreq',data.Nfreq(1),'removeDC',data.removeDC,...
        'window',data.window,'normalization',data.normalization);
    [cdata,time,frequency,options]=stft(signal(keep),time(keep),options);
    data.duration(1)=options.duration;
    data.skip(1)=options.skip;
    userdata=struct('yvar',frequency,'zvar',cdata);
    set(h.STFTImage,'XData',time,'UserData',userdata,'Visible','on');
    if strcmp(data.scaling,'log')
        set(h.STFTImage,'CData',10*log10(userdata.zvar));
    else
        set(h.STFTImage,'CData',userdata.zvar);
    end    
    label=sprintf('STFT spectrum for %s',data.name);
    title(h.STFTAxes,label,'Interpreter','none');
else
    userdata=get(h.STFTImage,'UserData');
    time=get(h.STFTImage,'XData');
end

hlabel=get(h.STFTAxes,'YLabel');
current_label=get(hlabel,'String');
old_label=get(hlabel,'UserData');
%if update.experimentSTFT || ~strcmp(old_label,current_label)
if update.experimentSTFT || update.experimentVariable
    %timeboundline=get(h.HistoryLine,'XData');
    switch current_label
        case 'Absolute frequency'
            yvar=userdata.yvar;
            boundpoints=data.flimitpoints;
            if ~isempty(data.tlimitpoints)
                boundcenterline = interp1(data.tlimitpoints,data.flimitpoints,time,'linear','extrap');
                boundminline = boundcenterline - data.fwidth/2;
                boundmaxline = boundcenterline + data.fwidth/2;
            end
        case 'Relative frequency'
            yvar=userdata.yvar-data.ref_frequency;
            if ~isempty(data.tlimitpoints)
                boundpoints=data.flimitpoints-data.ref_frequency;
                boundcenterline = interp1(data.tlimitpoints,data.flimitpoints,time,'linear','extrap') ...
                    - data.ref_frequency;
                boundminline = boundcenterline - data.fwidth/2;
                boundmaxline = boundcenterline + data.fwidth/2;
            end
        case 'Velocity'
            scale=(data.wavelength/2)*data.vscale;
            yvar=scale*(userdata.yvar-data.ref_frequency)+data.vlevel;
            if ~isempty(data.tlimitpoints)
                boundpoints=scale*(data.flimitpoints-data.ref_frequency);                
                boundcenterline = scale*(interp1(data.tlimitpoints,data.flimitpoints,time,'linear','extrap') ...
                    -data.ref_frequency)+data.vlevel;
                boundminline = (boundcenterline - scale*data.fwidth/2)+data.vlevel;
                boundmaxline = (boundcenterline + scale*data.fwidth/2)+data.vlevel;
            end
    end    
    set(h.STFTImage,'YData',yvar(:));
    if isempty(data.tlimitpoints)
        set(h.BoundPoints,'Visible','off');
        set(h.BoundCenterLine,'Visible','off');
        set(h.BoundMinLine,'Visible','off');
        set(h.BoundMaxLine,'Visible','off')
    else
       set(h.BoundPoints,'XData',data.tlimitpoints,'YData',boundpoints,...
           'Visible','on');
       set(h.BoundCenterLine,'XData',time,'YData',boundcenterline,...
           'Visible','on');
       set(h.BoundMinLine,'XData',time,'YData',boundminline,...
           'Visible','on');
       set(h.BoundMaxLine,'XData',time,'YData',boundmaxline,...
           'Visible','on')
    end
    axis(h.STFTAxes,'tight');
    zoom(h.STFTAxes,'reset');
    set(hlabel,'UserData',current_label);
end


% update display
if isempty(userdata)
    % do nothing
elseif strcmp(data.scaling,'log')
    set(h.STFTImage,'CData',10*log10(userdata.zvar));
    label='Intensity (dB)';
else
    set(h.STFTImage,'CData',userdata.zvar);
    label='Intensity';
end
set(h.STFTImage,'CDataMapping','scaled');
set(h.STFTAxes,'CLim',data.clim);
for n=1:numel(h.Colorbar)
    ylabel(h.Colorbar(n),label);
end
set_colormap(h.STFTAxes,data.map,data.invertmap);

% update history line (if necessary)
if update.history
    time=get(hsrc.SignalLine,'XData');
    signal=get(hsrc.SignalLine,'YData');
    keep=(time>=data.experiment(1)) & (time<=data.experiment(2));
    options=struct('duration',data.duration(end),'skip',data.skip(end),...
        'Nfreq',data.Nfreq(end),'removeDC',data.removeDC,...
        'window',data.window,'normalization',data.normalization);
    options.update.tlimitpoints = data.tlimitpoints;
    options.update.flimitpoints = data.flimitpoints;
    options.update.fwidth = data.fwidth;
    options.local.method = data.method;
[result,tout,frequency,options]=stft(signal(keep),time(keep),options,...
        @findpeak,@updateoptions);
    set(h.HistoryLine,'XData',tout,'UserData',result,'Visible','on');
    axis(h.HistoryAxes,'tight');
    zoom(h.HistoryAxes,'reset');
    label=sprintf('Calculated history for %s',data.name);
    title(h.HistoryAxes,label,'Interpreter','none');
else
    result=get(h.HistoryLine,'UserData');
end

% update history line display
hlabel=get(h.HistoryAxes,'YLabel');
current_label=get(hlabel,'String');
old_label=get(hlabel,'UserData');
%if update.history || ~strcmp(current_label,old_label)    
if update.history || update.experimentVariable
    switch current_label
        case 'Absolute frequency'
            yvar=result(1,:);
        case 'Relative frequency'
            yvar=result(1,:)-data.ref_frequency;
        case 'Velocity'
            scale=(data.wavelength/2)*data.vscale;
            yvar=scale*(result(1,:)-data.ref_frequency)+data.vlevel;
    end    
    set(h.HistoryLine,'YData',yvar);
    axis(h.HistoryAxes,'tight');
    set(hlabel,'UserData',current_label);
end

% pass data structure to all figures
update.experimentSTFT=false;
update.history=false;
update.experimentVariable=false;
data.update=update;
set(fig,'UserData',data);
zoom(fig,'reset');
figure(fig);

end

function ChangeVariable(varargin)

src=varargin{1};
checked=get(src,'Checked');
if strcmp(checked,'on')
    return
end

fig=varargin{3};
data=get(fig,'UserData');
haxes=[data.handle{2}.STFTAxes data.handle{2}.HistoryAxes];

parent=get(src,'Parent');
children=get(parent,'Children');
set(children,'Checked','off');
set(src,'Checked','on');
label=get(src,'Label');
for n=1:numel(haxes)
    target=get(haxes(n),'YLabel');
    set(target,'String',label);
end

data.update.experimentVariable=true;
set(fig,'UserData',data);
updateGUI(fig);

end

function PreviousButton(varargin)

fig=varargin{3};
SelectionScreen(fig);

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