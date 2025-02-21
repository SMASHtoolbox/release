% analyzeSinusoid Analyze sinusoidal signal(s)
%
% This program analyzed sinusoidal measurements acquired on
% Agilent/Keysight, LeCroy, and Tektronix digitizers.  Running the program:
%   analyzeSinusoid;
% initiates a graphical user interface for loading digitizer files (*.bin,
% *.h5, *.trc, and *.wfm).  All measurement channels stored in the file are
% loaded simultaneously; function records (Fourier transforms, etc.) are
% ignored . Sinusoid analysis on each channel generates the following
% results.
%   -Sinusoid frequency
%   -Sinusoid amplitude
%   -RMS noise amplitude
%   -Noise fraction
% Signal and spectrum visualization are also provided.
%

%
% created December 9, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=analyzeSinusoid(filename)

% manage input
if (nargin<1) || isempty(filename)
    filename='';    
end
assert(ischar(filename),'ERROR: invalid file name');

% launch GUI
createGUI(filename);

% manage output
if isdeployed
    varargout{1}=0;
end

end

%% GUI
function createGUI(filename)

%
dlg=SMASH.MUI.Dialog('FontSize',12);
dlg.Hidden=true;
dlg.Name='Sinusoid analysis';
%set(dlg.Handle,'Tag','SMASH.Z.analyzeSinusoid',...
%    'DefaultUIControlFontSize',12);

setappdata(dlg.Handle,'SignalData',[]);
setappdata(dlg.Handle,'SignalIndex',[]);
setappdata(dlg.Handle,'FrequencyBounds',[0 inf]);
setappdata(dlg.Handle,'CommonFrequencyBounds',true);

% file select and load
shortname='';
ext='';
hFile=addblock(dlg,'edit','Digitizer file:',60);
set(hFile(2),'String',filename,'Callback',@loadFile);
    function loadFile(varargin)
        % read and verify file name
        filename=get(hFile(2),'String');
        if isempty(filename)
            return
        elseif exist(filename,'file') ~= 2
            errordlg('Requested file does not exist','File error');
            return
        end       
        [~,shortname,ext]=fileparts(filename);
        switch lower(ext)
            case {'.h5' '.bin'}
                format='keysight';
                report=SMASH.FileAccess.probeFile(filename,format);
                N=report.NumberSignals;
                keep=false(N,1);
                for n=1:N
                    if strfind(report.GroupName{n},'/Waveforms/Channel')
                        keep(n)=true;
                    end
                end       
                index=find(keep);
            case '.trc'
                format='lecroy';
                index=1;
            case {'.wfm' '.isf'}
                format='tektronix';
                index=1;
            otherwise
                format='column';
                index=1;
        end
        % read signal(s)        
        N=numel(index);
        data=cell(N,1);
        hm=msgbox('Reading digitizer file...please wait','Reading file');        
        for n=1:N
            data{n}=SMASH.SignalAnalysis.Signal(filename,format,index(n));
        end
        if ishandle(hm)
            delete(hm);        
        end
        setappdata(dlg.Handle,'SignalData',data);             
        setappdata(dlg.Handle,'SignalIndex',index)       
        set(hActive(2),'String',sprintf('%d ',index));
        % fupdate requency bounding as needed
        if ~getappdata(dlg.Handle,'CommonFrequencyBounds');
            bound=getappdata(dlg.Handle,'FrequencyBounds');
            if size(bound,1) ~= N
                setappdata(dlg.Handle,'CommonFrequencyBounds',true);
                setappdata(dlg.Handle,'FrequencyBounds',[0 inf]);
            end
        end
        % update table
        updateTable();        
    end

hLoad=addblock(dlg,'button',{' Select file ' 'Load file '});
set(hLoad(1),'Callback',@selectFile)
    function selectFile(varargin)       
        [filename,pathname]=uigetfile('*.*','Select signal file');
        if isnumeric(filename)
            return
        end
        filename=fullfile(pathname,filename);
        set(hFile(2),'String',filename);
        loadFile;
    end

set(hLoad(2),'Callback',@loadFile)

% summary table
rows=8;
hTable=addblock(dlg,'table',...
    {'Channel' 'Frequency (Hz)' 'Amplitude (V)' 'Noise (V)' 'Fraction (%)'},...
    [],rows);
ColumnFormat={'char' 'char' 'char' 'char' 'char'}; 
set(hTable(end),'ColumnEditable',false,'ColumnFormat',ColumnFormat);

    function updateTable()
        data=getappdata(dlg.Handle,'SignalData');
        index=getappdata(dlg.Handle,'SignalIndex');
        bound=getappdata(dlg.Handle,'FrequencyBounds');
        if getappdata(dlg.Handle,'CommonFrequencyBounds')            
            bound=repmat(bound,[numel(index) 1]);
        end
        data=data(index);
        bound=bound(index,:);
        N=numel(index);
        value=cell(N,5);
        hm=msgbox('Analyzing channel(s)...please wait','Analyzing');
        for n=1:N
            report=summarize(data{n},'sinusoid',...
                'FrequencyBound',bound(n,:));
            value{n,1}=sprintf('%d',index(n));
            temp=SMASH.General.enprint(report.Sinusoid.Frequency,6);
            value{n,2}=temp(2:end);
            value{n,3}=sprintf('%.5f',report.Sinusoid.Amplitude);
            value{n,4}=sprintf('%.5f',report.Sinusoid.Noise);
            value{n,5}=sprintf('%#.3g',report.Sinusoid.Fraction*100);
        end
       if ishandle(hm)
            delete(hm);
       end
        set(hTable(end),'Data',value);
    end

% frequency bounding
hBound=addblock(dlg,'button','Set frequency bounds');
set(hBound(1),'Callback',@setBounds)
    function setBounds(varargin)
        index=getappdata(dlg.Handle,'SignalIndex');
        N=numel(index);
        subdlg=SMASH.MUI.Dialog;
        subdlg.Hidden=true;
        subdlg.Name='Frequency bounds';
        %
        h=addblock(subdlg,'text','Frequency bounds');
        set(h,'FontWeight','bold');
        hCommon=addblock(subdlg,'check','Common bounds');
        set(hCommon,...
            'Value',getappdata(dlg.Handle,'CommonFrequencyBounds'),...
            'Callback',@setCommon);
        function setCommon(varargin)
            value=logical(get(hCommon,'Value'));
            if value
                data=cell(1,3);
                data{1}='(all)';
                new=SMASH.General.enprint(0);
                data{2}=new(2:end);
                new=SMASH.General.enprint(inf);
                data{3}=new(2:end);
            else
                index=getappdata(dlg.Handle,'SignalIndex');
                N=numel(index);
                data=cell(N,3);
                for nbc=1:N
                    data{nbc,1}=sprintf('%d',index(nbc));
                    new=SMASH.General.enprint(0);
                    data{nbc,2}=new(2:end);
                    new=SMASH.General.enprint(inf);
                    data{nbc,3}=new(2:end);
                end
            end
            setappdata(dlg.Handle,'CommonFrequencyBounds',value);
            set(ht(end),'Data',data);
        end
        ht=addblock(subdlg,'table',{'Channel' 'Minimum' 'Maximum'},...
            [1 15 15],10);
        bound=getappdata(dlg.Handle,'FrequencyBounds');
        if getappdata(dlg.Handle,'CommonFrequencyBounds')
            data=cell(1,3);
            data{1}='(all)';
            new=SMASH.General.enprint(bound(1));
            data{2}=new(2:end);
            new=SMASH.General.enprint(bound(2));
            data{3}=new(2:end);
        else
            index=getappdata(dlg.Handle,'SignalIndex');
            N=numel(index);
            data=cell(N,3);
            for nb=1:N
                data{nb,1}=sprintf('%d',index(nb));
                new=SMASH.General.enprint(bound(nb,1));
                data{nb,2}=new(2:end);
                new=SMASH.General.enprint(bound(nb,2));
                data{nb,3}=new(2:end);
            end
        end
        set(ht(end),'Data',data,...
            'ColumnEditable',[false true true],...
            'CellEditCallback',@editBounds);
        function editBounds(src,eventdata)
            data=get(src,'Data');
            index=eventdata.Indices;
            % verify numeric input
            new=sscanf(eventdata.NewData,'%g');
            if isempty(new)
                new=eventdata.PreviousData;
            else               
                new=SMASH.General.enprint(new,6);
                new=new(2:end);
            end           
            data{index(1),index(2)}=new;
            % verify bounds
            minimum=sscanf(data{index(1),2},'%g');
            maximum=sscanf(data{index(1),3},'%g');
            if maximum>minimum
                % do nothing
            else
                data{index(1),index(2)}=eventdata.PreviousData;
            end
            % save results
            set(src,'Data',data);
        end
        %
        doneBounds=addblock(subdlg,'button',{'Done' 'Cancel'});
        set(doneBounds(1),'Callback',@processBounds);
        function processBounds(varargin)
            data=get(ht(end),'Data');
            N=size(data,1);
            bound=nan(N,1);
            for n=1:N
                bound(n,1)=sscanf(data{n,2},'%g');
                bound(n,2)=sscanf(data{n,3},'%g');
            end
            setappdata(dlg.Handle,'FrequencyBounds',bound);
            setappdata(dlg.Handle,'CommonFrequencyBounds',...
                logical(get(hCommon,'Value')));
            updateTable();
            delete(subdlg);
        end
        set(doneBounds(2),'Callback',@cancelBounds)
        function cancelBounds(varargin)
            delete(subdlg);
        end
        %
        locate(subdlg,'center',dlg.Handle);
        subdlg.Hidden=false;       
        subdlg.Modal=true;
    end

% view channel selection
hActive=addblock(dlg,'edit_button',{'View channels: ' ' Reset '},20);
set(hActive(2),'Callback',@setActive)
    function setActive(varargin)
        choice=get(hActive(2),'String');
        choice=sscanf(choice,'%g');
        N=numel(choice);
        keep=false(1,N);
        valid=getappdata(dlg.Handle,'SignalIndex');        
        for n=1:numel(choice)
            if any(choice(n)==valid)
                keep(n)=true;
            end            
        end
        choice=choice(keep);
        set(hActive(2),'String',sprintf('%d ',choice));
        %updateTable()
    end
set(hActive(3),'Callback',@resetActive)
    function resetActive(varargin)
        choice=getappdata(dlg.Handle,'SignalIndex');
        set(hActive(2),'String',sprintf('%d ',choice));       
    end

% visualization
hPlot=addblock(dlg,'button',{' View signals ' ' View spectra '});
set(hPlot(1),'Callback',@viewSignals);
    function viewSignals(varargin)
        index=sscanf(get(hActive(2),'String'),'%g');
        N=numel(index);
        if N==0
            return
        end
        SMASH.MUI.Figure('Name','Digitizer signals','NumberTitle','off');
        data=getappdata(dlg.Handle,'SignalData');        
        color=lines(N);               
        for n=1:N
            subplot(N,1,n);
            h=view(data{index(n)},gca);
            set(h,'Color',color(n,:));       
            temp=sprintf('"%s" (channel %d)',[shortname ext],index(n));
            title(temp,'Interpreter','none','FontWeight','normal')
            ylabel('Signal (V)');
            if n==N
                xlabel('Time (s)');
            end
        end
    end

set(hPlot(2),'Callback',@viewSpectra)
    function viewSpectra(varargin)
        index=sscanf(get(hActive(2),'String'),'%g');
        N=numel(index);
        if N==0
            return
        end
        SMASH.MUI.Figure('Name','Power spectra','NumberTitle','off');
        data=getappdata(dlg.Handle,'SignalData');
        color=lines(N);
        table=get(hTable(end),'Data');
        for n=1:N
            subplot(N,1,n);      
            [f,P]=fft(data{index(n)},...
                'RemoveDC',true,'NumberFrequencies',1e6);            
            h=plot(f,P);
            set(h,'Color',color(n,:));            
            temp=sprintf('"%s" (channel %d)',[shortname ext],index(n));
            title(temp,'Interpreter','none','FontWeight','normal');
            ylabel('Spectral power (arb)');
            set(gca,'YScale','log');
            if n==N
                xlabel('Frequency (Hz)');
            end
            yb(1)=min(P(2:end));
            yb(2)=max(P);
            ylim(yb);
            %                                      
            label={'frequency' 'amplitude' 'noise' 'fraction'};
            unit={' Hz' ' V' ' V' '%'};
            width=[0 0 0];
            for m=1:4
                width(1)=max(width(1),numel(label{m}));
                width(2)=max(width(2),numel(table{n,m+1}));
                width(3)=max(width(3),numel(unit{m}));
            end
            format=sprintf('%%%ds = %%%ds%%-%ds',width);
            for m=1:4
                label{m}=sprintf(format,label{m},table{n,m+1},unit{m});
            end            
            text('String',label,...
                'Units','normalized','Position',[0.95 0.95],...
                'FontName','fixedwidth',...
                'HorizontalAlignment','right',...
                'VerticalAlignment','top')
        end
    end

% control exit
%hDone=addblock(dlg,'button',' Done ');
%set(hDone,'Callback',@done);
hm=uimenu('Label','Program');
uimenu(hm,'Label','Change directory','Callback',@changeDirectory);
    function changeDirectory(varargin)
        directory=uigetdir(pwd,'Choose directory');
        if isempty(directory)
            return
        end
        cd(directory);
    end
uimenu(hm,'Label','Exit','Callback',@done)
    function done(varargin)        
        choice=questdlg('Are you finished?','Exit',' Yes ',' No ', ' No ');
        if ischar(choice)
            choice=strtrim(lower(choice));
        end
        switch choice
            case 'yes'
                delete(dlg);
        end
    end
set(dlg.Handle,'CloseRequestFcn',@done);

% online documentation
hm=uimenu('Label','Help');
uimenu(hm,'Label','About this program','Callback',@AboutProgram);
uimenu(hm,'Label','Using this program','Callback',@ProgramHelp,...
    'Enable','off');

% finish dialog
set(dlg.Handle,'HandleVisibility','callback');
locate(dlg,'center');
dlg.Hidden=false;

end

%%
function AboutProgram(varargin)

message={};
message{end+1}='Sinusoid analysis program';
message{end+1}='Version 1.0';
message{end+1}='December 2015';

h=msgbox(message,'','modal');
uiwait(h);

end

%%
function ProgramHelp(varargin)

end