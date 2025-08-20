function fig=createGUI(object)

%% create figure
fig=SMASH.MUI.Figure('Name','SIRHEN 2.0','Tag','SIRHEN',...
    'NumberTitle','off','IntegerHandle','off');
fig.Hidden=true;
set(fig.Handle,'Tag','SIRHEN');

% create controls
hm=uimenu(fig.Handle,'Label','Program');
uimenu(hm,'Label','Start over','Callback',@startOver);
    function startOver(varargin)
        location=fileparts(fileparts(mfilename('fullpath')));
        temp=mfilename('fullpath');
        temp=fileparts(fileparts(temp));
        [~,command]=fileparts(temp);
        command=fullfile(location,[command '.m']);
        delete(fig.Handle);
        run(command);
    end

uimenu(hm,'Label','Load session file','Callback',@loadSession,...
    'Separator','on');
    function loadSession(varargin)       
        [filename,pathname]=uigetfile({'*.sda;*.SDA' 'Sandia Data Archive files'},...
            'Select archive file');
        if isnumeric(filename)
            return
        end
        filename=fullfile(pathname,filename);
        try
            list=SMASH.FileAccess.probeFile(filename,'sda');
            if isscalar(list)
                object=SMASH.FileAccess.readFile(filename,'sda');
            else
                object=SMASH.FileAccess.readFile(filename,'sda','SIRHEN session');     
            end
            assert(isa(object,'SMASH.Velocimetry.PDV'),'');
        catch
            errordlg('SIRHEN data not found in this archive');               
        end
        updateObject(object);
    end
uimenu(hm,'Label','Save session file','Callback',@saveSession);
    function saveSession(varargin)
         object=getappdata(fig.Handle,'PDVdata');
         [filename,pathname]=uiputfile({'*.sda;*.SDA' 'Sandia Data Archive files'},...
            'Select archive file');
        if isnumeric(filename)
            return
        end
        filename=fullfile(pathname,filename);
        memo=sprintf('PDV measurement from SIRHEN');
        deflate=getappdata(fig.Handle,'FileCompression');
        SMASH.FileAccess.writeFile(filename,'-overwrite',...
            'SIRHEN session',object,memo,deflate);
    end
uimenu(hm,'Label','Export text file','Callback',@exportSession);
    function exportSession(varargin)
        object=getappdata(fig.Handle,'PDVdata');
        if isempty(object)
            return
        end
        object.ExportMode=getappdata(fig.Handle,'ExportFormat');
        export(object);
    end
if ~isdeployed
    uimenu(hm,'Label','Load object','Callback',@variable2session,...
        'Separator','on');
    uimenu(hm,'Label','Save object','Callback',@session2variable);

end
    function variable2session(varargin)
        commandwindow();
        while true
           choice=input('Choose variable name: ','s'); 
           if isempty(choice)
               break
           elseif ~isvarname(choice)
               fprintf('   Invalid variable name\n');
               continue
           end                                     
           command=sprintf('exist(''%s'',''var'')',choice);
           if evalin('base',command)
               object=evalin('base',choice);
               updateObject(object);
               break
           else
               fprintf('   Variable not found');
               continue
           end              
        end       
        figure(fig.Handle);
    end
    function session2variable(varargin)
        commandwindow();
        while true
            choice=input('Choose variable name: ','s');
            if isempty(choice)
                break
            elseif ~isvarname(choice)
                fprintf('   Invalid variable name\n');
                continue
            end
            command=sprintf('exist(''%s'',''var'')',choice);
            if evalin('base',command)
                fprintf('   Variable name already in use\n');
                continue
            else
                assignin('base',choice,getappdata(fig.Handle,'PDVdata'));
                break
            end
        end
        figure(fig.Handle);
    end

uimenu(hm,'Label','Exit','Separator','on','Callback',@exitProgram);
    function exitProgram(varargin)
        delete(fig.Handle);
    end
% CloseRequestFcn

hm=uimenu(fig.Handle,'Label','File options');
sub=uimenu(hm,'Label','Archive compression');
for k=0:9
    h=uimenu(sub,'Callback',@setDeflate,'UserData',k);    
    if k == 0
        set(h,'Checked','on');
        label='0 (none)';
    elseif k== 9
        label='9 (maximum)';
    else
        label=sprintf('%d',k);
    end
    set(h,'Label',label);
end
    function setDeflate(src,varargin)
        setappdata(fig.Handle,'FileCompression',get(src,'UserData'));
        parent=get(src,'Parent');
        h=get(parent,'Children');
        set(h,'Checked','off');
        set(src,'Checked','on');
    end
setappdata(fig.Handle,'ArchiveDeflate',0);

sub=uimenu(hm,'Label','Export format');
uimenu(sub,'Label','Standard','Callback',{@setExportFormat,'standard'},...
    'Checked','on');
uimenu(sub,'Label','Compact','Callback',{@setExportFormat,'compact'});
    function setExportFormat(src,~,mode)         
        setappdata(fig.Handle,'ExportFormat',mode);        
        parent=get(src,'Parent');
        children=get(parent,'Children');
        set(children,'Checked','off');
        set(src,'Checked','on');
    end
setappdata(fig.Handle,'ExportFormat','standard'); 

hm=uimenu(fig.Handle,'Label','Help');
uimenu(hm,'Label','About SIRHEN','Callback',@aboutSIRHEN);
uimenu(hm,'Label','Using SIRHEN','Callback',@usingSIRHEN)
    function usingSIRHEN(varargin)
        source=fileparts(fileparts(mfilename('fullpath')));   
        source=fullfile(source,'doc','UsingSIRHEN.m');        
        target=fullfile(tempdir,'SIRHEN','doc');
        if ~exist(target,'dir')
            mkdir(target)
        end               
        temp=fullfile(target,'UsingSIRHEN.m');
        copyfile(source,temp,'f');
        publish(temp,'format','html','evalCode',false);                        
        target=fullfile(fullfile(target,'html','UsingSIRHEN.html'));
        web(target);
    end

TabGroup=uitabgroup(fig.Handle,'TabLocation','bottom',...
    'Units','pixels','Position',[0 0 1 1]);

ht=uitab(TabGroup,'Title','Measurement'); % files, wavelength, offsets, corrections
dlg=MeasurementDialog();
copy(dlg,ht);
delete(dlg);

ht=uitab(TabGroup,'Title','Analysis');
dlg=AnalysisDialog();
copy(dlg,ht);
delete(dlg);

%
NamePanel=uipanel(fig.Handle,'BorderType','none');
dlg=NameDialog();
trim(dlg);
copy(dlg,NamePanel);
delete(dlg);

PlotPanel=uipanel(fig.Handle,'BorderType','none');
set(fig.Handle,'SizeChangedFcn',@sizeFigure)
    function sizeFigure(varargin)
        pause(0.1);
        StopSizing=false;
        figpos=getpixelposition(fig.Handle);
        posA=getpixelposition(TabGroup); 
        if figpos(4) < posA(4)
            dy=posA(4)-figpos(4);
            figpos(4)=posA(4);
            figpos(2)=figpos(2)-dy;
            setpixelposition(fig.Handle,figpos);
            StopSizing=true;
        end
        Ly=getpixelposition(NamePanel);
        Ly=Ly(4);
        posB(1)=posA(1)+posA(3);
        if figpos(3) < 3*posA(3)
            figpos(3)=3*posA(3);
            setpixelposition(fig.Handle,figpos);
            StopSizing=true;
        end       
        posB(2)=0;
        posB(3)=figpos(3)-posB(1);        
        posB(4)=figpos(4)-Ly;
        setpixelposition(PlotPanel,posB);
        posB(2)=posB(4);
        posB(4)=Ly;
        setpixelposition(NamePanel,posB);
        posA(2)=figpos(4)-posA(4);
        setpixelposition(TabGroup,posA);        
        if StopSizing
            simulateMouseRelease();
        end        
    end
hp=findobj(fig.Handle,'Type','uipanel');
set(hp,'Units','pixels');
sizeFigure();

%%
control=guihandles(fig.Handle);
setappdata(fig.Handle,'UserControls',control);
disableControl(control);
setappdata(fig.Handle,'PDVdata',[]);

%% measurement callbacks
set(control.LoadChannel,'Callback',@loadChannel)
    function loadChannel(varargin)
        selection=selectFiles(fig.Handle);
        if isempty(selection)
            return
        end
        object=SMASH.Velocimetry.PDV(selection{:});
        object.Name='PDV measurement';
        setappdata(fig.Handle,'PDVdata',object);
        updateMeasurementSettings(object,'replot');
        enableControl(control);
        list=cell(size(object.Channel));
        for n=1:object.NumberChannels
            list{n}=sprintf('Channel %d',n);            
        end
        value=get(control.ChannelList,'Value');
        if value > object.NumberChannels
            value=object.NumberChannels;
        end
        set(control.ChannelList,'String',list,'Value',value);                
        set(control.MeasurementName,'String',object.Name);
        if object.NumberChannels == 1
            set(control.LinkOffsets,'Enable','off');
        else
            set(control.LinkOffsets,'Enable','on');
        end
        updatePartitionSettings(object);          
    end

set(control.ChannelList,'Callback',@selectChannel,'UserData',1);
    function selectChannel(varargin)
        current=get(control.ChannelList,'Value');
        previous=get(control.ChannelList,'UserData');
        if current == previous
            return
        end
        object=getappdata(fig.Handle,'PDVdata');        
        updateMeasurementSettings(object)
        set(control.ChannelList,'UserData',current);
    end

set(control.LinkOffsets,'Callback',@linkOffsets)
    function linkOffsets(varargin)
        if get(control.LinkOffsets,'Value')
            object=getappdata(fig.Handle,'PDVdata');
            index=get(control.ChannelList,'Value');
            for nn=1:object.NumberChannels
                object.OffsetFrequency(nn)=object.OffsetFrequency(index);
            end
            updateMeasurementSettings(object,'replot');
            setappdata(fig.Handle,'PDVdata',object);            
        end
    end

set(control.ChannelSettings,'CellEditCallback',@updateSettings)
    function updateSettings(varargin)
        object=getappdata(fig.Handle,'PDVdata');
        index=get(control.ChannelList,'Value');
        value(1)=object.Wavelength(index);
        value(2)=object.OffsetFrequency(index);
        value(3)=object.Bandwidth(index);
        value(4)=object.VelocityCorrection(index);
        data=get(control.ChannelSettings,'Data');        
        change=false;
        for nn=1:size(data,1)
            [temp,~,~,next]=sscanf(data{nn,2},'%g',1);
            if isempty(temp)
                data{nn,2}=sprintf(value(nn),'%g');
            else
                value(nn)=temp;
                change=true;
                data{nn,2}=data{nn,2}(1:(next-1));
            end
        end
        if change
            object.Wavelength(index)=value(1);
            object.OffsetFrequency(index)=value(2);
            object.Bandwidth(index)=value(3);
            object.VelocityCorrection(index)=value(4);
            updateMeasurementSettings(object,'replot');
        end
        setappdata(fig.Handle,'PDVdata',object);
    end

set(control.ChannelActions,'Callback',@ChannelAction)
    function ChannelAction(varargin)
        if ~strcmpi(get(fig.Handle,'SelectionType'),'open')
            return
        end
        object=getappdata(fig.Handle,'PDVdata');
        target=findobj(fig.Handle,'Type','axes');
        change=false;
        replot='';
        switch get(control.ChannelActions,'Value')
            case 1 % Shift time base 
                object=shiftTime(object);
                replot='replot';
                change=true;
            case 2 % Scale time base
                object=scaleTime(object);
                replot='replot';
                change=true;
                updatePartitionSettings(object); 
            case 3 % Crop time base
                object=crop(object,target);
                change=true;
                replot='replot';
                updatePartitionSettings(object); 
            case 4 % Calculate offset
                index=get(control.ChannelList,'Value');
                if get(control.LinkOffsets,'Value')
                    object=calculateOffset(object,'Channel','common');
                else
                    object=calculateOffset(object,'Channel',index);
                end
                change=true;
                replot='replot';
            case 5 % Remove sinusoid
                index=get(control.ChannelList,'Value');
                object=removeSinusoid(object,'Channel',index);
                previous=[object.Partition.Points object.Partition.Skip];
                partition(object,'Points',getappdata(fig.Handle,'SpectrogramPoints'));
                object=partition(object,'Points',previous);
                change=true;
                replot='replot';
            case 6 % Show raw spectrogram(s)
                view(object,'raw');
            case 7 % Show signal(s)
                view(object,'signal');
        end
        if change
            setappdata(fig.Handle,'PDVdata',object);
            updateMeasurementSettings(object,replot);
        end
    end

set(control.MeasurementName,'Callback',@changeName);
    function changeName(varargin)
        object=getappdata(fig.Handle,'PDVdata');
        object.Name=get(control.MeasurementName,'String');
        updateMeasurementSettings(object,'replot');
        setappdata(fig.Handle,'PDVdata',object);
    end

set(control.MeasurementComments,'Callback',@changeComments);
    function changeComments(varargin)
        object=getappdata(fig.Handle,'PDVdata');
        object=comment(object);
        setappdata(fig.Handle,'PDVdata',object);
    end


%% analysis callbacks
set(control.FFToptions,'Callback',@selectFFToptions)
    function selectFFToptions(varargin)
        object=getappdata(fig.Handle,'PDVdata');
        list={'FFTwindow' 'FFTbins' 'ShowNegativeFrequencies'};
        for nn=1:numel(list)
            data.(list{nn})=object.(list{nn});
        end        
        data=FFTdialog(data,fig.Handle);
        list={'FFTwindow' 'FFTbins' 'ShowNegativeFrequencies'};
        for nn=1:numel(list)
            object.(list{nn})=data.(list{nn});
        end
        setappdata(fig.Handle,'PDVdata',object);
        updateViewList(object);
    end

set(control.PartitionSettings,'CellEditCallback',@selectPartion);
    function selectPartion(source,TableData)
        object=getappdata(fig.Handle,'PDVdata');
        OldPartition=object.Partition;
        row=TableData.Indices(1);     
        column=TableData.Indices(2);
        value=readNumber(TableData.EditData,1);
        if isempty(value)
            switch row
                case [1 3 5]
                    source.Data{row,column}=TableData.PreviousData;
                    return
                case 2
                    value=OldPartition.Duration;
                case 4
                    value=0;
                case 6
                    value=OldPartition.Points;
            end
        end
        if any(row == [1 2 3 5 6]) && (value <= 0)
            source.Data{row,column}=TableData.PreviousData;
            return
        end                
        switch row
            case 1
                mode='duration';
                value=[value OldPartition.Advance];
            case 2
                mode='duration';
                value=[OldPartition.Duration value];
            case 3
                mode='blocks';
                value=[round(value) OldPartition.Overlap];
            case 4
                mode='blocks';
                value=[OldPartition.Blocks value];
            case 5
                mode='points';
                value=[round(value) OldPartition.Skip];
            case 6
                mode='points';
                value=[OldPartition.Points round(value)];
        end
        object=partition(object,mode,value);
        updatePartitionSettings(object);
        setappdata(fig.Handle,'PDVdata',object);
    end

set(control.AnalysisActions,'Callback',@AnalysisAction);
    function AnalysisAction(varargin)
        if ~strcmpi(get(fig.Handle,'SelectionType'),'open')
            return
        end
        object=getappdata(fig.Handle,'PDVdata');
        switch get(control.AnalysisActions,'Value')
            case 1 % Update spectrogram
                object=generateSpectrogram(object);
                delete(PlotPanel.Children);
                view(object,'spectrogram',PlotPanel);
            case 2 % Manage ROI
                target=findobj(fig.Handle,'Type','axes');
                object=selectROI(object,target);
                updateViewList(object);
            case 3 % Select reference                
                target=findobj(fig.Handle,'Type','axes');
                object=selectReference(object,target);            
                 updateViewList(object);
            case 4 % Generate history
                if isempty(object.ReferenceSelection)
                    errordlg('Reference selection needed for history analysis','Missing reference');
                    return
                end
                object=HistoryDialog(object,fig.Handle);
                updateViewList(object);
        end
        setappdata(fig.Handle,'PDVdata',object);
    end

set(control.ViewHistory,'Callback',@viewHistory);
    function viewHistory(varargin)
        if ~strcmpi(get(fig.Handle,'SelectionType'),'open')
            return
        end
        object=getappdata(fig.Handle,'PDVdata');
        switch get(control.ViewHistory,'Value')
            case 1
                view(object,'history');
            case 2
                view(object,'velocity');
            case 3
                view(object,'amplitude');
            case 4
                view(object,'overlay');
        end
    end

%% manage input
if (nargin > 1) && isa(object,'SMASH.Velocimetry.PDV')
    setappdata(fig.Handle,'PDVdata',object);
    updateObject(object);    
end

%%
locate(fig,'center');
show(fig);
set(fig.Handle,'HandleVisibility','callback');

%% helpers
    function updateObject(object)
        setappdata(fig.Handle,'PDVdata',object);
        control=getappdata(fig.Handle,'UserControls');
        enableControl(control);
        updateMeasurementSettings(object,'replot');
        updatePartitionSettings(object);
        list=cell(size(object.Channel));
        for n=1:object.NumberChannels
            list{n}=sprintf('Channel %d',n);            
        end
        set(control.ChannelList,'String',list,'Value',1); 
    end

    function updateMeasurementSettings(object,replot)
        if (nargin < 2) || isempty(replot)
            % do nothing
        elseif strcmpi(replot,'replot')
            try
            delete(PlotPanel.Children);
            catch
            end
            view(object,'spectrogram',PlotPanel);
        end
        %
        value=get(control.ChannelList,'Value');
        data=get(control.ChannelSettings,'Data');       
        data{1,2}=sprintf('%g',object.Wavelength(value));
        data{2,2}=sprintf('%g',object.OffsetFrequency(value));
        data{3,2}=sprintf('%g',object.Bandwidth(value));
        data{4,2}=sprintf('%g',object.VelocityCorrection(value));        
        set(control.ChannelSettings,'Data',data);
        set(control.MeasurementName,'String',object.Name);
        updateViewList(object);
    end 

    function updatePartitionSettings(object)
        data=get(control.PartitionSettings,'Data');
        data{1,2}=sprintf('%g',object.Partition.Duration);
        data{2,2}=sprintf('%g',object.Partition.Advance);
        data{3,2}=sprintf('%g',object.Partition.Blocks);
        data{4,2}=sprintf('%g',object.Partition.Overlap);
        data{5,2}=sprintf('%g',object.Partition.Points);
        data{6,2}=sprintf('%g',object.Partition.Skip);
        set(control.PartitionSettings,'Data',data);                
        setappdata(fig.Handle,'SpectrogramPoints',...
            [object.Partition.Points object.Partition.Skip]);
        updateViewList(object);

    end
    function updateViewList(object)
        switch lower(object.Status.History)
            case 'incomplete'
                set(control.ViewHistory,'BackgroundColor','w',...
                    'Enable','off');
            case 'complete'
                set(control.ViewHistory,'BackgroundColor','w',...
                    'Enable','on',...
                    'TooltipString','Double-click to view selection');
            case 'obsolete'
                set(control.ViewHistory,'BackgroundColor','y',...
                    'Enable','on',...
                    'TooltipString','Double-click to view *obsolete* selection');
        end
    end

   
end