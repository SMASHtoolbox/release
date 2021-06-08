% read/edit records for PointVISARGUI

%%%%%%%%%%%%%%%%
% main routine %
%%%%%%%%%%%%%%%%
function fig=ReadEditRecordGUI(record)

% input check
if nargin<1
    record=[];
end

fig=findobj('Tag','PointVISAR:ReadEditRecord');
if ishandle(fig) % GUI already exists--make active
    figure(fig);
else % generate the figure
    % locate main figure
    MainFig=findall(0,'Type','figure','Tag','PointVISAR');
    MainPos=get(MainFig, 'Position');
    MainUnits=get(MainFig, 'Units');
    % create figure
    func=MinimalFigure('Tag','PointVISAR:ReadEditRecord','NumberTitle','off',...
        'Units',MainUnits,'Position',MainPos,...
        'IntegerHandle','off',...
        'CloseRequestFcn',@ExitRecord,...
        'Name',['Settings for ''' record.Label '''']);
    % create record menu
    RecordMenu=uimenu('Label','Record');
    uimenu(RecordMenu,'Label','Label','Tag','SetLabel',...
        'Callback',@RecordMenuCallback);
    uimenu(RecordMenu,'Label','Notes','Tag','SetNotes',...
        'Callback', @RecordMenuCallback);
    uimenu(RecordMenu, 'Label', 'Cancel','Separator', 'on',...
        'Tag', 'cancel', 'Callback', @RecordMenuCallback);
    uimenu(RecordMenu, 'Label', 'Done', ...
        'Tag', 'done', 'Callback', @RecordMenuCallback);
    % create processing menu
    ProcessMenu = uimenu('Label', '&Processing', 'Tag', 'ProcessMenu');
    FilterSubMenu=uimenu(ProcessMenu, 'Label', 'Filter', 'Tag', 'FilterMenu');
    uimenu(FilterSubMenu, 'Label', 'None', 'Checked', 'on', ...
        'Tag', 'FilterNone', 'Callback', @ProcessMenuCallback);
    uimenu(FilterSubMenu, 'Label', 'Mean', ...
        'Tag', 'FilterMean', 'Callback', @ProcessMenuCallback);
    uimenu(FilterSubMenu, 'Label', 'Median', ...
        'Tag', 'FilterMedian', 'Callback', @ProcessMenuCallback);
    uimenu(FilterSubMenu, 'Label', 'Convolution', ...
        'Tag', 'FilterConvolution', 'Callback', @ProcessMenuCallback);
    uimenu(ProcessMenu, 'Label', 'Time shifting', 'Tag', 'SetTimeShifts', ...
        'Separator', 'on', 'Callback', @ProcessMenuCallback);
    uimenu(ProcessMenu, 'Label', 'Time scaling', 'Tag', 'SetTimeScale', ...
        'Callback', @ProcessMenuCallback);
    uimenu(ProcessMenu, 'Label', 'Signal shifting', ...
        'Tag', 'SetVerticalShifts', 'Callback', @ProcessMenuCallback,...
        'Separator','on');
    uimenu(ProcessMenu, 'Label', 'Signal scaling', ...
        'Tag', 'SetSignalScaling', 'Callback', @ProcessMenuCallback);
    % create experiment menu
    ExperimentMenu = uimenu('Label', '&Experiment', 'Tag', 'ExperimentMenu');
    uimenu(ExperimentMenu, 'Label', 'Fringe constant (VPF)', 'Tag', 'SetVPF', ...
        'Callback', @ExperimentMenuCallback);
    %sub=uimenu(ExperimentMenu,'Label','Analysis');
    %uimenu(sub,'Label','Velocity','Tag','VelocityAnalysis',...
    %    'Callback',@ExperimentMenuCallback);
    %uimenu(sub,'Label','Displacement','Tag','DisplacementAnalysis',...
    %    'Callback',@ExperimentMenuCallback);
    %uimenu(ExperimentMenu,'Label','System parameters',...
    %    'Tag','Parameters','Callback',@ExperimentMenuCallback);
    uimenu(ExperimentMenu, 'Label', 'VISAR ellipse', ...
        'Tag','FitEllipse','Callback', @ExperimentMenuCallback);
    uimenu(ExperimentMenu, 'Label', 'Initial velocity', ...
        'Tag', 'InitialVelocity', 'Callback', @ExperimentMenuCallback, ...
        'Separator', 'on');
    uimenu(ExperimentMenu, 'Label', 'Initial time range', ...
        'Tag', 'InitialTime', 'Callback', @ExperimentMenuCallback);
    %uimenu(ExperimentMenu, 'Label', 'Ellipse time range', ...
    %    'Tag', 'EllipseTime', 'Callback', @ExperimentMenuCallback);
    uimenu(ExperimentMenu, 'Label', 'Experiment time range', ...
        'Tag', 'ExperimentTime', 'Callback', @ExperimentMenuCallback);
    % create view menu
    ViewMenu = uimenu('Label', '&View', 'Tag', 'ViewMenu');
    uimenu(ViewMenu, 'Label', 'All plots', 'Tag', 'all', ...
        'Accelerator', '0', 'Callback', @ViewMenuCallback);
    uimenu(ViewMenu, 'Label', 'Raw signals', 'Tag', 'raw', ...
        'Accelerator', '1', 'Callback', @ViewMenuCallback);
    uimenu(ViewMenu, 'Label', 'Processed signals', 'Tag','processed',...
        'Accelerator', '2', 'Callback', @ViewMenuCallback);
    uimenu(ViewMenu, 'Label', 'Quadrature signals', 'Tag','quadrature1', ...
        'Accelerator', '3', 'Callback', @ViewMenuCallback);
    uimenu(ViewMenu, 'Label', 'Quadrature plot', 'Tag','quadrature2',...
        'Accelerator', '4', 'Callback', @ViewMenuCallback);
    % create panels
    [slider,panel]=FourPanels('Parent',func);
    colors=DistinguishedLinesRecord(1:4);
    %colors=get(0,'DefaultAxesColorOrder');
    % create raw signals axes
    ii=1;
    ha(ii) = axes('Parent',panel(ii),'Tag','RawSignals','Box','on');
    xlabel('Time');
    ylabel('Detector output');
    title('Raw signals', 'FontWeight', 'bold');
    hl=[];
    for jj=1:record.NumSignals
        hl(jj)=line('XData',[],'YData',[],...
            'Color',colors(jj,:),'Tag',record.SignalLabels{jj});
    end
    set(ha(ii),'UserData',hl);
    % create processed signals access
    ii=2;
    ha(ii) = axes('Parent',panel(ii),'Tag','ProcessedSignals','Box','on');
    xlabel('Time');
    ylabel('Detector output');
    title('Processed signals', 'FontWeight', 'bold');
    hl=[];
    for jj=1:record.NumSignals
        hl(jj)=line('XData',[],'YData',[],...
            'Color',colors(jj,:),'Tag',record.SignalLabels{jj});
    end
    set(ha(ii),'UserData',hl);
    % create quadrature signals axes
    ii=3;
    ha(ii) = axes('Parent',panel(ii),'Tag','QuadratureSignals','Box','on');
    xlabel('Time');
    ylabel('Reduced detector output');
    title('Quadrature signals', 'FontWeight', 'bold');
    hl=[];
    for jj=1:2
        hl(jj)=line('XData',[],'YData',[],'Color',colors(jj,:));
    end
    set(ha(ii),'UserData',hl);
    % create quadrature plot axes
    ii=4;
    ha(ii) = axes('Parent',panel(ii),...
        'Tag','QuadraturePlot','Box','on',...
        'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1],...
        'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',[1 1 1]);
    xlabel('D1');
    ylabel('D2');
    title('Quadrature plot', 'FontWeight', 'bold');
    hl=[];
    hl(end+1)=line('Tag','QuadratureData','Color',[0 0 1]);
    hl(end+1)=line('Tag','EllipseFit','Color',[0 0 0],'LineStyle','--','Visible','off');
    set(hl,'XData',[],'YData',[]);
    set(ha(ii),'UserData',hl);
    grid on
    % general formatting
    set(ha,'Box','on');
    % hide figure from command line users
    set(func,'HandleVisibility','callback');
end

UpdateGUI(record);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateGUI(record)      

fig=findall(0,'Type','figure','Tag','PointVISAR:ReadEditRecord');

record = VisarAnalysis(record, 'PreProcessing', 'QuadratureSignals');
set(fig,'UserData',record);

%switch record.Analysis
%    case 'velocity'
%        hm=findobj(fig,'Tag','VelocityAnalysis');
%        set(hm,'Checked','on');
%        hm=findobj(fig,'Tag','DisplacementAnalysis');
%        set(hm,'Checked','off');
%    case 'displacement'
%        hm=findobj(fig,'Tag','DisplacementAnalysis');
%        set(hm,'Checked','on');
%        hm=findobj(fig,'Tag','VelocityAnalysis');
%        set(hm,'Checked','off');
%end

numsignals=record.NumSignals;
%initial=record.InitialTime;
%experiment=record.ExperimentTime;
%trange=[min(record.Time) max(record.Time)];

% update raw signal plot
h=findobj(fig,'Tag','RawSignals');
axes(h);
hl=get(h,'UserData');
for ii=1:numsignals
    set(hl(ii),'XData',record.RawSignalTime{ii},'YData',record.RawSignal{ii});
end
%axis tight;
legend(hl,record.SignalLabels,'Location','Best');

% update processed signal plot
h=findobj(fig,'Tag','ProcessedSignals');
axes(h);
hl=get(h,'UserData');
for ii=1:numsignals
    set(hl(ii),'XData',record.SignalTime{ii},'YData',record.Signal{ii});
end
%ShowBounds(initial,experiment);
ShowBounds(record)
%axis tight;
legend(hl,record.SignalLabels,'Location','Best');

% update quadrature signal plot
h=findobj(fig,'Tag','QuadratureSignals');
axes(h);
hl=get(h,'UserData');
for ii=1:2
    set(hl(ii),'XData',record.Time,'YData',record.D{ii});
end
%axis tight
legend(hl,{'D1','D2'},'Location','Best');

% update quadrature plot
h=findobj(fig,'Tag','QuadraturePlot');
axes(h);
hl=get(h,'UserData');
set(hl(1),'XData',record.D{1},'YData',record.D{2});
if record.EllipseFit
    % make ellipse fit visible and display legend
    ellipseFitLine = findobj(fig, 'Tag', 'EllipseFit');
    % set(ellipseFitLine, 'XData', record.D{1}, 'YData', ...
    %    record.D{2});
    set(ellipseFitLine, 'Visible', 'on');

    EllipsePlot(record.Ellipse, 'overwrite', h);
end
%axis equal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ShowBounds(record)

% remove old bounding lines
hb=findobj(gca,'Tag','BoundLine');
delete(hb);
 
% create new bounding lines as necessary
hl=[];
initial=record.InitialTime;
%ellipse=record.EllipseTime;
experiment=record.ExperimentTime;
for ii=1:2
    if ~isinf(initial(ii))
        hl(end+1)=line('XData',repmat(initial(ii),[1 2]),'YData',ylim,'LineStyle','-.');
    end
    %if ~isinf(ellipse(ii))
    %    hl(end+1)=line('XData',repmat(ellipse(ii),[1 2]),'YData',ylim,'LineStyle',':');
    %end
    if ~isinf(experiment(ii))
        hl(end+1)=line('XData',repmat(experiment(ii),[1 2]),'YData',ylim,'LineStyle','--');
    end
end
set(hl,'Tag','BoundLine');

%%%%%%%%%%%%%%%%%%%%
% uimenu callbacks %
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecordMenuCallback(src,eventdata)

fig=ancestor(src,'figure');
record=get(fig, 'UserData');

choice=get(src, 'Tag');
switch choice
    case 'SetLabel'
        default = {record.Label};
        NumLines = 1;
        answer = inputdlg('Set record label', ...
            'Record label', NumLines, default);
        if isempty(answer) % user pressed cancel
            return
        end
        record.Label = answer{1};
        set(fig,'UserData',record,...
            'Name',['Files/settings for ''' record.Label '''']);
    case 'SetNotes'
        RecordNotesDialog(record);
    case 'cancel'
        ExitRecord(src);
    case 'done'
        record=get(fig,'UserData');        
        record=VisarAnalysis(record,'QuadratureSignals','PostProcessing');
        set(fig,'UserData',record);
        ExitRecord(src);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExperimentMenuCallback(src,eventdata)

fig=ancestor(src,'figure');
record = get(fig, 'UserData');

choice = get(src, 'Tag');
switch choice        
    %case 'VelocityAnalysis'
    %    status=get(src,'Checked');  
    %    if strcmpi(status,'off')
    %        record.Analysis='velocity';
    %        UpdateGUI(record);
    %    end
    %case 'DisplacementAnalysis'
    %    status=get(src,'Checked');
    %    if strcmpi(status,'off')
    %        record.Analysis='displacement';
    %        UpdateGUI(record);
    %    end
    %case 'Parameters'
    %    switch record.Analysis
    %        case 'velocity'
    %            prompt={'VPF (required):','Delay (optional):','Dispersion (optional):'};
    %            default={record.VPF, record.Delay, record.Dispersion};
    %            answer=DoubleInputDlg(prompt,'Parameters',default);
    %            if isempty(answer)
    %                return
    %            end
    %            record.VPF=answer{1};
    %            record.Delay=answer{2};
    %            record.Dispersion=answer{3};
    %            set(fig,'UserData',record);
    %        case 'displacement'
    %            prompt={'Delay (required):','Wavelength (required):',...
    %                'Dispersion (optional):','Derivative parameters (required)'};
    %            default={record.Delay, record.Wavelength, record.Dispersion, record.DerivativeParams};
    %            answer=DoubleInputDlg(prompt,'Parameters',default);
    %            if isempty(answer)
    %                return
    %            end
    %            record.Delay=answer{1};
    %            record.Wavelength=answer{2};
    %            record.Dispersion=answer{3};
    %            record.DerivativeParams=answer{4};
    %            set(fig,'UserData',record);
    %    end
    case 'SetVPF'
        answer = DoubleInputDlg({'VPF:'}, 'Specify VPF', record.VPF);
        if isempty(answer)
            return
        end
        record.VPF = answer; 
        set(fig,'UserData',record);
    case 'FitEllipse'
        record=EllipseFittingGUI(record);
        ReadEditRecordGUI(record);
    case 'InitialVelocity'
        answer = DoubleInputDlg({'v0='}, 'Initial velocity', ...
            record.InitialVelocity);
        if isempty(answer)
            return
        end
        record.InitialVelocity = answer;
        set(fig,'UserData',record);
    case 'InitialTime'
        prompt = {'Begin time', 'End time'};
        answer = DoubleInputDlg(prompt, 'Initial velocity duration', ...
            record.InitialTime);
        if isempty(answer)
            return
        end
        record.InitialTime = answer;
        ReadEditRecordGUI(record);
    %case 'EllipseTime'
    %    prompt = {'Begin time', 'End time'};
    %    answer = DoubleInputDlg(prompt, 'Ellipse duration', ...
    %        record.EllipseTime);
    %    if isempty(answer)
    %        return
    %    end
    %    record.EllipseTime = answer;
    %    ReadEditRecordGUI(record);
    case 'ExperimentTime'
        prompt = {'Begin time', 'End time'};
        answer = DoubleInputDlg(prompt, 'Experiment duration', ...
            record.ExperimentTime);
        if isempty(answer)
            return
        end
        record.ExperimentTime = answer;
        ReadEditRecordGUI(record);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ProcessMenuCallback(src,eventdata)

fig=ancestor(src,'figure');
record=get(fig,'UserData');

choice=get(src,'Tag');
switch choice
    case 'FilterNone'
        record.FilterName = '';
        record.FilterParams = [];
    case 'FilterMean'
        if (~strcmp(record.FilterName,'mean')) && (~strcmp(record.FilterName,'median'))
            [temp,record.FilterParams]=FilterSignal([],'mean');
        end
        record.FilterName='mean';
        %if isempty(record.FilterParams)
        %    [temp,record.FilterParams]=FilterSignal([],record.FilterName);
        %end
        record.FilterParams=DoubleInputDlg('Mean filter neighborhood: ', ...
            'Mean filter',record.FilterParams); 
    case 'FilterMedian'
        if (~strcmp(record.FilterName,'median')) && (~strcmp(record.FilterName,'mean'))
            [temp,record.FilterParams]=FilterSignal([],'median');
        end
        record.FilterName='median';
        %if isempty(record.FilterParams)
        %    [temp,record.FilterParams]=FilterSignal([],record.FilterName);
        %end
        record.FilterParams=DoubleInputDlg('Median filter neighborhood: ', ...
            'Median filter',record.FilterParams);
    case 'FilterConvolution'
        if ~strcmp(record.FilterName,'convolution')
            [temp,record.FilterParams]=FilterSignal([],'convolution');
        end
        record.FilterName='convolution';
       % if isempty(record.FilterParams)
       %     [temp,record.FilterParams]=FilterSignal([],record.FilterName);
       % end
        default=EditBoxNum2Str(record.FilterParams);
        answer=inputdlg('Enter the convolution kernel (space delimited): ', ...
            'Convolution filter',1,{default});
        if isempty(answer)
            % do nothing
        else
            record.FilterParams=sscanf(answer{1},'%g');
        end
    case 'SetTimeShifts'
        answer = DoubleInputDlg(record.SignalLabels, 'Time shifts', ...
            record.SignalTimeShift);
        if isempty(answer)
            return
        end
        record.SignalTimeShift = answer;
    case 'SetTimeScale'
        answer = DoubleInputDlg('Time scaling factor', 'Time scaling', ...
            record.SignalTimeScale);
        if isempty(answer)
            return
        end
        if answer<=0
            message{1}='Error: improper time scaling factor!';
            message{2}='Please choose a POSITIVE number';
            errordlg(message,'Improper scaling factor');
            ProcessMenuCallback(src,eventdata)
            return
        end
        % update all time quantities
        for jj=1:record.NumSignals
            record.RawSignalTime{jj}=...
                record.RawSignalTime{jj}/record.SignalTimeScale*answer;
            record.SignalTimeShift(jj)=...
                record.SignalTimeShift(jj)/record.SignalTimeScale*answer;
        end
        record.TimeShift=record.TimeShift/record.SignalTimeScale*answer;
        record.InitialTime=...
            record.InitialTime/record.SignalTimeScale*answer;
        record.ExperimentTime=...
            record.ExperimentTime/record.SignalTimeScale*answer;
        record.AddJumps=...
            record.AddJumps/record.SignalTimeScale*answer;
        record.SubtractJumps=...
            record.SubtractJumps/record.SignalTimeScale*answer;   
        record.SignalTimeScale = answer;
        record.JumpWidth=...
            record.JumpWidth/record.SignalTimeScale*answer;
    case 'SetVerticalShifts'
        answer = DoubleInputDlg(record.SignalLabels, 'Vertical shifts', ...
            record.SignalVerticalShift);
        if isempty(answer)
            return
        end
        record.SignalVerticalShift = answer;   
    case 'SetSignalScaling'
        answer = DoubleInputDlg(record.SignalLabels, 'Signal scaling', ...
            record.SignalScale);
        if isempty(answer)
            return
        end
        record.SignalScale = answer;             
end

% make sure proper menu items are checked
parent=get(src,'Parent');
tag=get(parent,'Tag');
if strcmp(tag,'FilterMenu')
    children=get(parent,'Children');
    set(children,'Checked','off');
    set(src,'Checked','on');
end

% store changes and update GUI
ReadEditRecordGUI(record);
%set(fig,'UserData',record);
%UpdateGUI(record);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ViewMenuCallback(src, eventdata)

choice = get(gcbo, 'Tag');
switch choice
    case 'all'
        value = [0.5 0.5 0.5];
    case 'raw'
        value = [1 0 0.5];
    case 'processed'
        value = [1 1 0.5];
    case 'quadrature1'
        value=[0 0.5 0];
    case 'quadrature2'
        value=[0 0.5 1];
end
FourPanels('SliderValue', value);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExitRecord(src,eventdata)

main=findall(0,'Type','figure','Tag','PointVISAR');
data=get(main,'UserData');
active=ActiveRecord(data);

fig=ancestor(src,'figure');
record=get(fig,'UserData');
tag=get(src,'Tag');
if strcmpi(tag,'done')
    record.NewRecord=false;
    if isempty(record.LineColor)
        record.LineColor=DistinguishedLines(active);
    end
    data{active}=record;
elseif record.NewRecord
    message{1}='Canceling this new record will delete it';
    message{2}='Are you sure you want to do this?';
    DlgTitle = 'Delete new record?';
    answer = questdlg(message, DlgTitle);
    if isnumeric(answer) || strcmpi(answer,'no') || strcmpi(answer,'cancel')
        return
    end    
    data(active)=[];       
    if numel(data)>0
        data{end}.Ative=true;
    end
else
    message = 'Discard changes and return to main window?';
    DlgTitle = 'Dischard changes?';
    answer = questdlg(message, DlgTitle);
    if isnumeric(answer) % user closed dialog window
        return
    end
     if isnumeric(answer) || strcmpi(answer,'no') || strcmpi(answer,'cancel')
        return
    end    
end
set(main,'Units',get(fig,'Units'),'Position',get(fig,'Position'));
delete(fig);
PointVISARGUI(data);
