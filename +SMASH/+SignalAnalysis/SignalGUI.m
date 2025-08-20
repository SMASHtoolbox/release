%% SignalGUI is a GUI interface for the SMASH.SignalAnalysis.Signal package
%
% To open the GUI simply call the method:
%   >> SMASH.SignalAnalysis.SignalGUI
%
% There are four menus: Signal, Edit, Analyze, Plot.
% In addition to the menu bar, two toolbars are available. The one next to
% the help  toolbar is 'Selected Signals' and is a shortcut to the 'Choose
% Active Signals' option in the edit menu bar. The next toolbar to the
% right, 'Clear all Signals', deletes all signal objects for a fresh start.
%
%-Signal 
% Load : Load multiple ascii or *.sda files into signal objects. For
%   SignalGroup type data, the first column is taken as the grid and
%   subesequent columns are loaded as distinct signals.
% Load from multicolumn : Select a data/grid pair from a multi-column text
%   file.1
% Labels : Change the labels of each signal object
% Comment : Change comments associated with object. Only *.sda files track
%   comments, ascii files do not.
% Save: Save to an ascii or *.sda file   
%
%-Edit
% Choose active signal : choose which signals to plot/edit/analyze
% Shift and scale : shift/scale grid and data arrays. An @(x) f(x) handle 
%   definition will apply the function scale mapping. eg. @(x) log10(x). 
% Limit : apply the limit method
% Regrid : Apply the regrid method. Also supplies an option for a "pchip"
%   interpolation regrid.
%
%-Analyze
% Differentiate : apply differentiate method
% Integrate : apply integrate method
% Calculate power spectrum : apply fft method
% Locate feature : apply locate method
%
%-Plot
% Creates plots of presentation/report quality. Uses many of the options in
% the Graphics package
% Update Line Properties : Saves any changes to the line properties of the
%   signal
% Edit signal order : Provides an interface to change the order of the
%   signals
% Edit axis labels : Change the grid and data labels
% Single column AIP figure : Single column report figure
% Double column AIP figure : Double column report figure
% Axis inset : creates an axis inset on the selected figure. Warning: the
%   algorithm deletes figures not associated with this GUI.
% Axis limit : modifies the axis range for the selected figure. Warning:
%   the algorithm deletes figures not associated with this GUI.
%

%% created February,1 2014 by Justin Brown (Sandia National Laboraties)
% Moved to Signal package and stripped down capabilities Apr 3, 2018

%%
function SignalGUI()
clear all; clc;

% Initialize Variables
sig = {}; 
sig_tot = 0;
sig_num = [];

%Reset callback is limited to the latest pathname
pathname = [];

% create figure if not already running
check=findobj('Name','SMASH Signal GUI');
if ishandle(check) % program is already running
    disp('GUI already running!');
    figure(check);
    return;
end

fig = SMASH.MUI.Figure; fig.Hidden = true;
fig.Name = 'SMASH Signal GUI';
set(fig.Handle,'Tag','SignalGUI');
set(fig.Handle,'Units','centimeters');
%set(fig.Handle,'Position',[0.05 0.05 .75 .8]);
set(fig.Handle,'Toolbar','figure');
ha=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0 0 1 1]);
SMASH.Graphics.DisplayTools.scaleFigure(150,fig.Handle)
%SMASH.Graphics.DisplayTools.scaleDefaultFonts(125);


%Create active signal toolbar button using Matlab icon
[X map] = imread(fullfile(...
    matlabroot,'toolbox','matlab','icons','HDF_VData.gif'));
    % Convert indexed image and colormap to truecolor
    icon = ind2rgb(X,map);
ht=uipushtool('Parent',fig.ToolBar,'Separator','on',...
    'Tag','Clear','ToolTipString','Select Signals',...
    'CData',icon,'ClickedCallback',@ActiveSignal);


%Create clear toolbar button using Matlab icon
[X map] = imread(fullfile(...
    matlabroot,'toolbox','matlab','icons','HDF_filenew.gif'));
    % Convert indexed image and colormap to truecolor
    icon = ind2rgb(X,map);
ht=uipushtool('Parent',fig.ToolBar,'Separator','off',...
    'Tag','Clear','ToolTipString','Clear all signals',...
    'CData',icon,'ClickedCallback',@ClearCallback); 

function ClearCallback(varargin)
            sig = {};
            sig_tot = 0;
            figure(fig.Handle); cla; legend('off');
            
            fighandles = findobj('type','figure');
            fignames = get(fighandles,'name');
            if ~iscell(fignames); fignames = {fignames}; end;
            for i = 1:numel(fignames)
            	if strcmp(fignames{i}, 'Active Signal')
                    delete(fighandles(i));
                end
            end
    end



%% create Signal menu
hm=uimenu(fig.Handle,'Label','Signal');
uimenu(hm,'Label','Load','Callback',@LoadSignal);
uimenu(hm,'Label','Load from Multicolumn','Callback',@LoadMultiSignal);
uimenu(hm,'Label','Labels','Callback',@Label);
uimenu(hm,'Label','Comment','Callback',@Comment);
uimenu(hm,'Label','Export','Callback',@SaveSignal);
%uimenu(hm,'Label','Close');


%% create Edit menu
hm=uimenu(fig.Handle,'Label','Edit');
uimenu(hm,'Label','Choose Active Signal(s)','Callback',@ActiveSignal);
uimenu(hm,'Label','Shift and Scale','Callback',@ShiftScale);
uimenu(hm,'Label','Limit','Callback',@LimitSignal);
uimenu(hm,'Label','Smooth','Callback',@SmoothSignal);
uimenu(hm,'Label','Regrid','Callback',@RegridSignal);
%uimenu(hm,'Label','Reset Active Signals','Callback',@ResetSignal);


%% create Analyze menu
hm=uimenu(fig.Handle,'Label','Analyze');
uimenu(hm,'Label','Differentiate','Callback',@Derivative);
uimenu(hm,'Label','Integrate','Callback',@Integral);
uimenu(hm,'Label','Calculate power spectrum','Callback',@PowerSpectrum);
uimenu(hm,'Label','Locate feature','Callback',@LocateFeature);


%% create Plotting menu
hm=uimenu(fig.Handle,'Label','Plot');
uimenu(hm,'Label','Update Line Properties','Callback',@UpdateLineProp);
uimenu(hm,'Label','Edit Signal Order','Callback',@EditOrder);
uimenu(hm,'Label','Edit axis labels','Callback',@EditAxisLabel);
uimenu(hm,'Label','Single column AIP Figure','Callback',@AIPFigure1);
uimenu(hm,'Label','Double column AIP Figure','Callback',@AIPFigure2);
uimenu(hm,'Label','Axes Inset','Callback',@AIPAxesInset);
uimenu(hm,'Label','Axis Limits','Callback',@SetAxis);
uimenu(hm,'Label','Print Plot','Callback',@PrintPlot);

fig.Handle.Resize = 'on';
movegui(fig.Handle,'center');
fig.Hidden = false;


%%%%%%%%%%% Signal Callbacks %%%%%%%%%%%%%

%% Load callback
function LoadSignal(src,varargin)     

%Pick file
[filename, pathname, filterindex] = uigetfile({'*.*',  'All Files (*.*)'}, ...
    'Pick Signal(s)', 'MultiSelect', 'on');

if (~filterindex); return; end  %Pressed cancel

%Determine how many files selected
if ~iscellstr(filename); filename={filename}; end
numfiles = length(filename);

%Create waitbar
wb=SMASH.MUI.Waitbar('Loading Signals');

%Loop through and load
for i=1:numfiles
     
    try
    
    %Load .sda record
    [~,~,ext]=fileparts(filename{i});
    if strcmp(ext,'.sda')
        %Probe file
        SDAobj =  SMASH.FileAccess.SDAfile(fullfile(pathname,filename{i}));
        [label,type,description,status] = probe(SDAobj);
        
        for ii = 1:length(label)
             %Advance to next record
             update(wb,(ii*i)/(numfiles*length(label)));
             sig_tot = sig_tot+1;
             sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename{i}),'sda',label{ii});
        end
        
    %Load textronix file    
    elseif strcmp(ext,'.wfm')
        %Advance to next signal
        sig_tot = sig_tot+1;
        
        sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename{i}),'tektronix');
        %Set some object properties
        sig{sig_tot}.GraphicOptions.LineWidth=3;
        sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
        sig{sig_tot}.GridLabel= 'x'; sig{sig_tot}.DataLabel= 'y';
        
    %Load ascii file    
    else
        %Advance to next signal
        sig_tot = sig_tot+1;
        
        %Probe file to find number of columns
        source=SMASH.FileAccess.ColumnFile(fullfile(pathname,filename{i}));
        p=probe(source); ncol = p.NumberColumns;

        if ncol == 1
            data = read(source); data = data.Data;
            x=[1:length(data)];
            sig{sig_tot} = SMASH.SignalAnalysis.Signal(x,data);
        else
            %If grid is not monotonically increasing use unique
            try
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename{i}),'column');
            catch
                data = read(source); data = data.Data;
                [~,index] = unique(data(:,1));
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(data(index,1),data(index,2));
            end

        end
        
        [~,name,ext]=fileparts(filename{i}); 
        if length(ext) > 4; name = [name ext]; end
        sig{sig_tot}.Name = name;

        %Set some object properties
        sig{sig_tot}.GraphicOptions.LineWidth=3;
        sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
        sig{sig_tot}.GridLabel= 'x'; sig{sig_tot}.DataLabel= 'y';

    
        %Loop through column numbers 2 and higher and load if there is data
        if ncol > 2; data = read(source); end; 
        for cn=3:ncol
            if ~(all(data.Data(:,cn)==0)) %Make sure there is data in column
            %Increment total number signals, load and save to object
            sig_tot = sig_tot + 1;
            sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename{i}),'column',[1 cn]);  
            str=sprintf('%s col%i',name,cn);
            sig{sig_tot}.Name = str;

            %Set some object properties
            sig{sig_tot}.GraphicOptions.LineWidth=3;
            sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
            sig{sig_tot}.GridLabel= 'x'; sig{sig_tot}.DataLabel= 'y';
            end
        end
    end
    
    %Reset if any errors during load process
    catch
        warning('Invalid file selected, try another one');
    end
        
    
    %update waitbar and exit if it doesn't exist
    if ~ishandle(wb.Handle); return; end;
    update(wb,i/numfiles);   
end
delete(wb);

%Set active signals to all and plot
sig_num = [1:sig_tot];
plotdata(fig.Handle,sig,sig_num);

    
end %Load Signal

%% Load 2 columns from a multicolumn ascii file
function LoadMultiSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LoadDialog');
if ishandle(dlg)
    return;
end

dlg.Hidden = true;
dlg.Name = 'LoadDialog';
locate(dlg,'center')

direct = dir('*.*');
for i = 3:length(direct);
    filelist{i-2} = direct(i).name;
end
h1=addblock(dlg,'popup','Select Signal(s)',filelist);
cols = {'Column 1', 'Column2','','','','',''}; 
h2=addblock(dlg,'listbox','Select Column',cols);
h=addblock(dlg,'check','Flip Column Order');   
h=addblock(dlg,'button',{'Load','Cancel'});    


%Set multiple selection option (for all in dlg)
dlg_hc = get(dlg.Handle,'Children');
set(dlg_hc,'Max',2);
set(h1(2),'Callback',@FileCallback);

%Define callbacks
function FileCallback(varargin)

    filename = probe(dlg);
    filename = filename{1};
    %filename=fullfile(pwd,probe(dlg));
    %Probe file to find number of columns
    source=SMASH.FileAccess.ColumnFile(filename);
    p=probe(source); ncol = p.NumberColumns;
    data = read(source);
   
    header =strread(data.Header{1},'%s');
    if length(header) == ncol
        str = header;
    else
        str = {};
        for i =1:ncol
            str{1,i}=num2str(i);
        end
    end
    set(h2(2),'String',str);
    
end

set(h(1),'Callback',@ApplyCallback);
function ApplyCallback(varargin)
    value = probe(dlg);
    filename = value{1};
    source=SMASH.FileAccess.ColumnFile(filename);
   
    cols=get(dlg_hc(4),'Value');
   
    try
        sig_tot = sig_tot+1;
        if ~value{3}
                      
            %If grid is not monotonically increasing use unique
            try
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(filename),'column',cols(1:2));
            catch
                data = read(source); data = data.Data;
                [~,index] = unique(data(:,cols(1)));
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(data(index,cols(1)),data(index,cols(2)));
            end
            
        else
            %If grid is not monotonically increasing use unique
            try
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(filename),'column',fliplr(cols(1:2)));
            catch
                data = read(source); data = data.Data;
                [~,index] = unique(data(:,cols(2)));
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(data(index,cols(2)),data(index,cols(1)));
            end
            
        end

        %Set some object properties
        [~,name,ext]=fileparts(filename); 
        if length(ext) > 4; name = [name ext]; end
        pathname = pwd;
        sig{sig_tot}.Name = name;
        sig{sig_tot}.GraphicOptions.LineWidth=3;
        sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
        sig{sig_tot}.GridLabel= 'x'; sig{sig_tot}.DataLabel= 'y';

        %Set active signals to all and plot
        sig_num = [1:sig_tot];
        plotdata(fig.Handle,sig,sig_num);
    
    %Reset if any errors during the load process
    catch
        sig_tot = numel(sig);
        warning('Invalid load options, try selecting two valid columns');
    end

end
set(h(2),'Callback',@CancelCallback);
function CancelCallback(varargin)
   delete(dlg);
end

dlg.Hidden = false;
    

end %Load multi-column signal

%% Label signal callback
function Label(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LabelDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Label Signal';
locate(dlg,'center');

%Create edit box for each signal
for i=1:numel(sig_num)
    h=addblock(dlg,'edit',sig{sig_num(i)}.Name); set(h(2),'String', sig{sig_num(i)}.Name);
end
h=addblock(dlg,'button',{ 'Apply Label Change', 'Cancel'});
dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       newnames = probe(dlg);
       for i=1:numel(sig_num)
        if ~isempty(newnames{i})
            sig{sig_num(i)}.Name = newnames{i};
        end
       end
    plotdata(fig.Handle,sig,sig_num);
    delete(dlg);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
end %Label 

%% Comment signal callback
function Comment(src,varagin)

    for i=1:numel(sig_num)
        sig{sig_num(i)}=comment(sig{sig_num(i)});
    end

end %Comment

%% Save signal callback
function SaveSignal(src,varargin)     


   %Set save to all active signals
   savenum = sig_num;
   for i = 1:numel(savenum)
       [savename, savepath] = uiputfile({'*.dat;*.txt;*.out','All ASCII Files'; '*.sda','SandiaDataArchive'; ...
           '*.*','All Files'}, sprintf('Save Signal #%i',savenum(i)),sig{savenum(i)}.Name);

       %savename = inputdlg(sig{savenum(i)}.Name,'Select file to write',1,{horzcat(sig{savenum(i)}.Name,'.dat')});
       %savename = savename{1}; savepath = pathname;
        
       %Export all objects to Sandia Data Archive if .sda extension, otherwise ASCII
       [~,~,ext]=fileparts(savename);
       if strcmp(ext,'.sda')
          
           for i=1:numel(savenum)
               labelnames{i} = sig{i}.Name;
           end
           [~,ia] = unique(labelnames);
           %duplicates = labelnames;
           %duplicates(ia)=[];
           duplicate_ind = setxor(ia,1:numel(labelnames));
           for i=1:length(duplicate_ind)
               warning(sprintf('Duplicate label name detected : %s',labelnames{duplicate_ind(i)}));
               labelnames{duplicate_ind(i)} = sprintf('%s%i',labelnames{duplicate_ind(i)},i);
           end
           
           for i = 1:numel(savenum)
            %labelname = inputdlg('Enter label name for sda file','SDA Label',1,{sig{savenum(i)}.Name}); labelname = labelname{1};
            %labelname = sig{savenum(i)}.Name;
            %export(sig{savenum(i)},fullfile(savepath,savename),labelname);
            %store(sig{savenum(i)},fullfile(savepath,savename),labelnames{i});
            
            archive=SMASH.FileAccess.SDAfile(savename);
            description=sprintf('%s object',class(sig{savenum(i)}));
            deflate=1;
            insert(archive,labelnames{i},sig{savenum(i)},description,deflate);
            %h5writeatt(filename,['/' label],'Class',class(sig{savenum(i)}));
            %h5writeatt(filename,['/' label],'RecordType','object');
            
            
           end
           return; %Only ask for sda name once
       else
           
        % Modify nature of the default export
        %[x y] = limit(sig{savenum(i)});
        %table=[x(:) y(:)];        
        %format='%#+.6e %#+.6e \n';
        %header{1}=sprintf('# Signal export on %s',datestr(now));
        %header{2}=sprintf('# column format: %s %s',sig{savenum(i)}.GridLabel,sig{savenum(i)}.DataLabel);
        %SMASH.FileAccess.writeFile(fullfile(savepath,savename),table,format,header);         
        %dlmwrite(fullfile(savepath,savename),table,'delimiter','\t','precision','%8.6e');
        
        export(sig{savenum(i)},fullfile(savepath,savename));
       end  
   end



end %Save


%%%%%%%%%%% Edit Callbacks %%%%%%%%%%%%%

%% Active signal callback
function ActiveSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'ActiveDialog');
if ishandle(dlg)
    %location = get(dlg,'OuterPosition');
    return;
end


dlg.Hidden = true;
dlg.Name = 'Active Signal';

for i =1:sig_tot; slist{i}=sig{i}.Name; end

h=addblock(dlg,'listbox','Select Signal(s)',slist);

%Set multiple selection option (for all in dlg)
dlg_hc = get(dlg.Handle,'Children');
set(dlg_hc,'Max',2);
h=addblock(dlg,'button',{ 'Apply', 'Delete','Cancel'});

%Define callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       sig_num=get(dlg_hc(1),'Value');
       plotdata(fig.Handle,sig,sig_num);
       
       %Update if new signal has been added
       if (numel(sig) > numel(get(dlg_hc(1),'String')))
        delete(dlg); ActiveSignal(src,'ActiveDialog');
       end
    end
    
    set(h(2),'Callback',@DeleteCallback);
    function DeleteCallback(varargin)
        sig_del=get(dlg_hc(1),'Value');
        delete(dlg);
        
        %Renumber signals
        new_num = 1; new_sig={};
        check = ~ismember([1:sig_tot],sig_del);
        for i=1:sig_tot;
            if check(i)
                new_sig{new_num}=sig{i}; 
                new_num=new_num+1;
            end
        end
        
        %Clear old signals then update
        clear sig; sig = new_sig; clear new_sig;
        sig_tot = numel(sig);
        sig_num = [1:sig_tot];
        
        %Reset colors
        %for i=1:sig_tot;
        %    sig{i}.GraphicOptions.LineColor=DistinguishedLines(i);
        %end
        
        %If all signals were deleted, reset
        if new_num == 1
            sig = {};
            sig_tot = 0;
            figure(fig.Handle); cla; legend('off');
            return;
        end
            
        plotdata(fig.Handle,sig,sig_num);      
        ActiveSignal(0);
    end
    
    set(h(3),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
    

locate(dlg,'east');
dlg.Hidden = false;

end %Choose Active Signals

%% Shift and Scale
function ShiftScale(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'ShiftScaleDialog');
if ishandle(dlg)
    return
end

init = [1 0 1 0];
dlg.Hidden = true;
dlg.Name='Shift and Scale Profile';
hb = addblock(dlg,'button',{'SI-km/s','km/s-SI','SI-ns'});
h=addblock(dlg,'edit','x scale'); set(h(2),'String', init(1));
h=addblock(dlg,'edit','x shift'); set(h(2),'String', init(2));
h=addblock(dlg,'edit','y scale'); set(h(2),'String', init(3));
h=addblock(dlg,'edit','y shift'); set(h(2),'String', init(4));

set(hb(1),'Callback',@fromSICallback);
function fromSICallback(varargin)
    %Hardcode "probe" to allow modification of values
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4];
    editdata = [1e6 0 1e-3 0];
    for i=1:4
        set(dlg_hc(hloc(i)),'String',num2str(editdata(i)));
    end
    
    for i=1:numel(sig_num)
        sig{i}.GridLabel = 'Time (\mus)';
        sig{i}.DataLabel = 'Velocity (km/s)';
    end
    
end

set(hb(2),'Callback',@toSICallback);
function toSICallback(varargin)
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4];
    editdata = [1e-6 0 1e3 0];
    for i=1:4
        set(dlg_hc(hloc(i)),'String',num2str(editdata(i)));
    end

    for i=1:numel(sig_num)
        sig{i}.GridLabel = 'Time (s)';
        sig{i}.DataLabel = 'Velocity (m/s)';
    end    
    
end

set(hb(3),'Callback',@toNSCallback);
function toNSCallback(varargin)
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4];
    editdata = [1e9 0 1e-3 0];
    for i=1:4
        set(dlg_hc(hloc(i)),'String',num2str(editdata(i)));
    end

    for i=1:numel(sig_num)
        sig{i}.GridLabel = 'Time (ns)';
        sig{i}.DataLabel = 'Velocity (km/s)';
    end    
    
end


OkApplyCancel(dlg,@applyedit,'overlay_all')
function newsig = applyedit(n)    
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4]; value = [];
    for i=1:4
        editdata(i) = str2double(get(dlg_hc(hloc(i)),'String'));
    end

  %Apply edit to signal number n
        
        if strncmpi(get(dlg_hc(hloc(1)),'String'),'@(x)',4);
            funchand = str2func(get(dlg_hc(hloc(1)),'String'));
            newsig = sig{n}.map('Grid','custom',funchand);
        else
            newsig = scale(sig{n},editdata(1));
        end
        
        newsig = shift(newsig,editdata(2));
        
        if strncmpi(get(dlg_hc(hloc(3)),'String'),'@(x)',4);
            funchand = str2func(get(dlg_hc(hloc(3)),'String'));
            newsig = newsig.map('Data','custom',funchand);
        else
            newsig = newsig*editdata(3);
        end
        
        newsig = newsig+editdata(4);       
 end     

locate(dlg,'east');
dlg.Hidden=false;

end %ShiftScale

%% Limit signal callback
function LimitSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LimitDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Limit Signal';


limits = [-inf inf];
h=addblock(dlg,'edit','Lower Bound'); set(h(2),'String', limits(1));
h=addblock(dlg,'edit','Upper Bound'); set(h(2),'String', limits(2));
h=addblock(dlg,'button','SelectPoints');
set(h(1),'Callback',@selectpoints);
dlg_hc = get(dlg.Handle,'Children');

function [varargout] = selectpoints(varargin)
    figure(fig.Handle); 
    [xpick ypick] = ginput(2);
    figure(dlg.Handle);
    set(dlg_hc(4),'String',num2str(min(xpick)));
    set(dlg_hc(2),'String',num2str(max(xpick)));
end

OkApplyCancel(dlg,@applylimit,'overlay','redo');

function newsig = applylimit(n)    
        value = probe(dlg);
        clipbounds = str2double(value);
        newsig = limit(sig{n},clipbounds);
end     

locate(dlg,'east');
dlg.Hidden=false;

end %Limit (clip) signals

%% Smooth signal callback
function SmoothSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'SmoothDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Smooth Signal';

h=addblock(dlg,'listbox','Smooth Method',{'mean','kernel'}); 
h=addblock(dlg,'edit','Smooth Value');

OkApplyCancel(dlg,@applysmooth,'overlay')

function newsig = applysmooth(n)
    
    %Add defaults if smooth options are empty
    value = probe(dlg);
    dlg_hc = get(dlg.Handle,'Children');
    if strcmp(value(2),'')
        if strcmp(value(1),'kernel')
            set(dlg_hc(4),'String','fft kernel');
        else 
            set(dlg_hc(4),'String','3');
        end
    end
    
    %Apply smoothing choice
    choice = value{1};
        switch choice
            case 'mean'
                newsig = smooth(sig{n},'mean',str2double(value(2)));
            case 'kernel'
                kernel = definekernal;
                newsig = smooth(sig{n},'kernel',kernel);
        end
        
    function  [kernel] = definekernal
        [tempsigx tempsigy] = limit(sig{n}); 
        xfilt = str2double(value(2));
        Nsmooth=int32(length(tempsigx)./xfilt); %LowPassFilt
        kernel = ones(Nsmooth,1);
        kernel = kernel/sum(kernel);
    end        
        
end
locate(dlg,'east')
dlg.Hidden=false;


end %Smooth signals

%% Regrid signal callback
function RegridSignal(src,varargin)
    
    % see if dialog already exists
    dlg=FindOrCreateDlg(src,'RegridDialog');
    if ishandle(dlg)
        return
    end

    dlg.Hidden = true;
    dlg.Name = 'Regrid Signal';

    h=addblock(dlg,'edit_check',{'Number Points to Regrid','pchip'});

    OkApplyCancel(dlg,@applyregrid,'overlay')

    function newsig = applyregrid(n)
        value = probe(dlg);
        N = str2double(value(1));
        
        if isfinite(N)
            [xcurr ycurr] = limit(sig{n}); 
            x1=min(xcurr);
            x2=max(xcurr);
            spacing=(x2-x1)/(N-1);
            x=x1:spacing:x2;
            x=x(:);
            if ~value{2}
                newsig = regrid(sig{n},x);
            else
                y = interp1(xcurr, ycurr, x, 'pchip', 0);
                newsig = SMASH.SignalAnalysis.Signal(x,y);
            end
            clear xcurr ycurr;
        else
            %If inf or nan, then regrid to signal 1
            newsig = regrid(sig{n},sig{1}.Grid);
        end
    end
    
    dlg.Hidden = false;
end %Regrid

%% Reset signal callback
function ResetSignal(src,varagin)
for i = 1:numel(sig_num)
    previous = sig{sig_num(i)}
    previous = SMASH.SignalAnalysis.Signal('import',fullfile(pathname,previous.Source),'column',previous.SourceRecord);
    
    %Reset properties
    sig{sig_num(i)} = reset(sig{sig_num(i)},previous); 
    clear previous; 
    
    plotdata(fig.Handle,sig,sig_num);
end

end  %Reset



%%%%%%%%%%% Analyze Callbacks%%%%%%%%%%%%%
%% Derivative
function Derivative(src,varargin)
    for i=1:numel(sig_num)
    sig{sig_num(i)}=differentiate(sig{sig_num(i)});
    end
    plotdata(fig.Handle,sig,sig_num);
end %Derivative

%% Integral
function Integral(src,varargin)
    for i=1:numel(sig_num)
    sig{sig_num(i)}=integrate(sig{sig_num(i)});
    end
    plotdata(fig.Handle,sig,sig_num);
end %Integral

%% Power spectrum
function PowerSpectrum(src,varargin)
    for i=1:numel(sig_num)
    [frequency{i}, power{i}] = fft(sig{sig_num(i)},'NumberFrequencies',[1 inf]);
    end
    
    figure; 
    hold on; hold all;
    for i=1:numel(sig_num)
        output{i}=10*log10(power{i});
        plot(frequency{i},output{i});
    end
    xlabel('Frequency')
    ylabel('Power (dB scale)');
end %Power spectrum

%% Locate feature (peak fitting)
function LocateFeature(src,varargin)
    for i=1:numel(sig_num)
    report =locate(sig{sig_num(i)});
    x = report.Location; 
    y = lookup(sig{sig_num(i)},x);
    line([x x],[0 y],'Color','k','LineStyle','--','LineWidth',3);
    end
end %Locate peak




%%%%%%%%%%% Plotting Callbacks %%%%%%%%%%%%%

%% Update Line Properties
function UpdateLineProp(src,varargin)

%% Save current line properties to signal
lh = findobj(gca,'Type','line');
if ~isempty(lh)
    color = get(lh,'Color');
    if ~iscell(color); color = {color}; end;
    style = get(lh,'LineStyle');
    if ~iscell(style); style = {style}; end;
    width = get(lh,'LineWidth');
    if ~iscell(width); width = {width}; end;
    mark = get(lh,'Marker');
    if ~iscell(mark); mark = {mark}; end;
    marksize = get(lh,'MarkerSize');
    if ~iscell(marksize); marksize = {marksize}; end;
    
    %Update as long as signal numbering is OK
    if (numel(color) == numel(sig_num))
        for i = 1:numel(sig_num);
            index = numel(color)+1-i;
            sig{sig_num(i)}.GraphicOptions.LineWidth=width{index,1};
            sig{sig_num(i)}.GraphicOptions.LineColor=color{index,1};
            sig{sig_num(i)}.GraphicOptions.LineStyle=style{index,1};
            sig{sig_num(i)}.GraphicOptions.Marker=mark{index,1};
            sig{sig_num(i)}.GraphicOptions.MarkerSize=marksize{index,1};
        end
    end
end
end %Update line properties

%% Signal order callback
function EditOrder(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'OrderDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Order Signal';
locate(dlg,'south');

%Create edit box for each signal
for i=1:numel(sig_num)
    h=addblock(dlg,'edit',sig{sig_num(i)}.Name); set(h(2),'String', num2str(i));
end
h=addblock(dlg,'button',{ 'Apply Order Change', 'Cancel'});
dlg.Hidden = false

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       values = probe(dlg); newindex =[];
       for i = 1:numel(values);
           newindex(i)=int32(str2num(values{i}));
       end

       if ~isequal(numel(unique(newindex)),numel(sig_num));
           h = addblock(dlg,'text',sprintf('Not a valid index selection. Require %i distinct integers',numel(sig_num)));
           return;
       end
       
       newsig = {};
       for i = 2:numel(sig_num);
           newsig{i} = SMASH.SignalAnalysis.Signal(0,0);
       end
       
       for i=1:numel(sig_num)
           newindex(i)
          sig_num(i)
            newsig{newindex(i)} = sig{sig_num(i)};
       end
       sig = newsig;
       clear newsig;

       plotdata(fig.Handle,sig,sig_num);
       delete(dlg);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
end %Order 

%% Label signal callback
function EditAxisLabel(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'AxisLabelDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Axis Labels';

%Create edit box for each signal
h=addblock(dlg,'edit','Grid Axis Label'); set(h(2),'String', sig{sig_num(1)}.GridLabel);
h=addblock(dlg,'edit','Data Axis Label'); set(h(2),'String', sig{sig_num(1)}.DataLabel);

h=addblock(dlg,'button',{ 'Apply Label Change', 'Cancel'});

dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       newnames = probe(dlg);
       for i=1:numel(sig_num)
            sig{i}.GridLabel = newnames{1};
            sig{i}.DataLabel = newnames{2};
       end
    plotdata(fig.Handle,sig,sig_num);
    delete(dlg);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
end %Label 


%% Single column AIP
function AIPFigure1(src,varargin)
    AIP = SMASH.Journal.PublishedFigure; AIP.Visible = 'off';
    AIP.Width = 1; AIP.Height = 1;
    %AIP.Height = 1/1.618; %Golden Ratio
    set(AIP.Handle,'name','AIP Single Column Fig');
    
    
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=2; end;
    plotdata(AIP.Handle,sig,sig_num)
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=3; end;
    
    %set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    set(gcf,'Color','w'); box on;
    xlabel(sig{sig_num(1)}.GridLabel);
    ylabel(sig{sig_num(1)}.DataLabel);   
    AIP.Scale = 300;
    AIP.Visible = 'on';

end %AIP single column

%% Double column AIP
function AIPFigure2(src,varargin)
    AIP = SMASH.Journal.PublishedFigure; AIP.Visible = 'off';
    AIP.Width = 2; 
    AIP.Height = 1.5; %Matlab default: 1.333 ratio
    %AIP.Height = 2/1.618; %Golden Ratio
    set(AIP.Handle,'name','AIP Double Column Fig');
    
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=2; end;
    plotdata(AIP.Handle,sig,sig_num)
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=3; end;
    
    %set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    %box off; 
    set(gcf,'Color','w'); box on;
    xlabel(sig{sig_num(1)}.GridLabel);
    ylabel(sig{sig_num(1)}.DataLabel);
    AIP.Scale = 200; 
    AIP.Visible = 'on';
    
end %AIP double column

%% Create dual axes plot
function DualAxes(src,varargin)
    AIP = SMASH.Journal.PublishedFigure; AIP.Visible = 'off';
    AIP.Width = 2; AIP.Height = 2; AIP.Scale = 200; 
    set(AIP.Handle,'name','Dual Axis Fig');
    ax1 = axes; ax2 = axes;
    linkaxes([ax1 ax2],'x');
    
    %Plot all signals except last
    axes(ax1);
    if ~isempty(sig_num)
        legendentry = [];
        for i=1:length(sig_num)-1
            ph(i) = view(sig{sig_num(i)},AIP.Handle);
            legendentry{i}=strrep(sig{sig_num(i)}.Name,'_','\_');
        end
     
     axis tight;

    
     %Plot last signal on right axis
     set(ax2,'YAxisLocation','right','Color','none','YColor',sig{sig_num(i+1)}.GraphicOptions.LineColor);
     axes(ax2);
     ph(i+1) = line(sig{sig_num(i+1)}.Grid,sig{sig_num(i+1)}.Data);
     %apply(sig{sig_num(i+1)}.GraphicOptions,ph(i+1));
     set(ph(i+1),'Color',sig{sig_num(i+1)}.GraphicOptions.LineColor,'LineWidth',sig{sig_num(i+1)}.GraphicOptions.LineWidth, ...
         'LineStyle',sig{sig_num(i+1)}.GraphicOptions.LineStyle);
     %ph(i+1)=view(sig{sig_num(i+1)},AIPFig);
     %ph(i+2)=view(sig{sig_num(i+2)},ax2);    
     legendentry{i+1}=strrep(sig{sig_num(i+1)}.Name,'_','\_');
     %legendentry{i+2}=strrep(sig{sig_num(i+2)}.Name,'_','\_');
     legend(ph,legendentry,'Color','none','Location','Best','EdgeColor','w');
     legend('boxoff');
     
     
    set(ax1,'XColor','w'); 
    xlabel(ax2,sig{sig_num(1)}.GridLabel); 
    ylabel(ax1,sig{sig_num(1)}.DataLabel); ylabel(ax2,sig{sig_num(end)}.DataLabel);
    %set(ax1,'FontName','times','FontAngle','normal','FontSize',30);
    %set(ax2,'FontName','times','FontAngle','normal','FontSize',30);
    set(gcf,'Color','w'); 
    pause(0.1);
    ax1.Position = ax2.Position;

    end

end %Dual axes

%% Create an inset
function AIPAxesInset(src,varargin)
    
AxisMod(0,@inset);
    function [h] = inset(limits)
        hobj = SMASH.Graphics.AxesTools.Inset(gca);
        hobj.XBound = limits(1:2);
        hobj.YBound = limits(3:4);
    end
    

    
end %Inset

%% Define axis limits
function SetAxis(src,varargin)
    
AxisMod(0,@changeaxis);

    function [] = changeaxis(limits)
        axis(limits);
    end
    
end %Limits


%% Print current plot
function PrintPlot(src,varargin)
    x = inputdlg({'Plot Name','Resolution (dpi)','Extension (eg. png, bmp, tiff, pdf, epsc)'},'Print Plot', [1 40;1 20;1 20],{'Plot','150','png'}); 
    
    fighandles = findobj('type','figure');
    pfig = fighandles(2);
    
    appD = getappdata(fighandles(2));
    
    if isfield(appD,'PublishedFigure')
        obj = appD.PublishedFigure;
        fname = [x{1},'.',x{3}];
        %print(obj,fname,str2num(x{2})); %Doesn't render in painters?
        scale = obj.Scale;
        obj.Scale = 100;
        print(pfig,x{1},['-d' x{3}],['-r' x{2}],'-painters');
        obj.Scale = scale;
    else
        print(pfig,x{1},['-d' x{3}],['-r' x{2}],'-painters');
    end


end %Limits



%%
function Template(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'TempDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Temp Signal';
h=addblock(dlg,'edit','Lower Bound');
dlg.Hidden = false;

OkApplyCancel(dlg,@FUN,'overlay');

function newsig = IM(n)
    newsig = sig{n};
end

end



























%Create OkApplyCancel button and execute the passed function handle
function OkApplyCancel(varargin)
    if (nargin < 2)
        error('Require (dialog handle, function handle)')
    else
        dlg = varargin{1};
        func = varargin{2};
        options = 'none';
        redo = 'none';
    end
    if (nargin == 3); options = varargin{3}; redo = 'none'; end;
    if (nargin == 4); options = varargin{3}; redo = varargin{4}; end;
    newsig = sig;
    
    
h=addblock(dlg,'button',{'Apply','OK','Cancel'});
%Define callbacks
set(h(1),'Callback',@ApplyCallback);
function ApplyCallback(varargin)
    
    for i = 1:length(sig_num)
    newsig{sig_num(i)} = func(sig_num(i)); 
    end 
    
    if strcmp(options,'overlay')
        plotdata(fig.Handle,sig,sig_num);
        plotdata(fig.Handle,newsig,sig_num,'overlay');
    elseif strcmp(options,'overlay_all')
        plotdata(fig.Handle,sig,sig_num);
        plotdata(fig.Handle,newsig,sig_num,'overlay_all');     
        plotdata(fig.Handle,newsig,sig_num,'overlay');      
    else
        plotdata(fig.Handle,newsig,sig_num);
    end
    figure(dlg.Handle);
end

set(h(2),'Callback',@OKCallback);
function OKCallback(varargin)
    for i = 1:length(sig_num)
        if strcmp(redo,'redo')
            sig{sig_num(i)} = func(sig_num(i)); 
        else
            %Don't redo the apply calculation if it's been done
            if numel(newsig{sig_num(i)}.Grid) > 1
                sig{sig_num(i)}=reset(sig{sig_num(i)},newsig{sig_num(i)});
            else
                sig{sig_num(i)}=reset(sig{sig_num(i)},func(sig_num(i)));
            end
        end
    end
    plotdata(fig.Handle,sig,sig_num);
    clear newsig; clear previous;
    if ~strcmp(options,'preserve'); delete(dlg); end
end

set(h(3),'Callback',@CancelCallback);
function CancelCallback(varargin)
    plotdata(fig.Handle,sig,sig_num);
    delete(dlg);  clear newsig;  
end
end


%% Axis modification
function AxisMod(src,varargin)

    if (nargin < 1)
    error('Require function handle')
    else
        func = varargin{1};
    end
    
    %Close all figures expect those of potential interest
    fighandles = findobj('type','figure');
    fignames = get(fighandles,'name'); 
    if ~iscell(fignames); fignames = {fignames}; end;
    for i=1:numel(fignames);
        switch fignames{i}
            case 'SMASH Signal GUI'
            case 'AIP Large Fig'
            case 'AIP Single Column Fig'
            case 'AIP Double Column Fig'
            otherwise
                close(fighandles(i));
        end
    end
    fighandles = findobj('type','figure');
    fignames = get(fighandles,'name');
    if ~iscell(fignames); fignames = {fignames}; end;
    
    % see if dialog already exists
    dlg=FindOrCreateDlg(src,'AxesInsetDialog');
    if ishandle(dlg)
        return
    end

    dlg.Hidden = true;
    dlg.Name = 'Axis Modification';

    h=addblock(dlg,'listbox','Select Figure',fignames);
    h=addblock(dlg,'edit','xmin        '); set(h(2),'String',min(sig{sig_num(1)}.Grid));
    h=addblock(dlg,'edit','xmax        '); set(h(2),'String',max(sig{sig_num(1)}.Grid));
    h=addblock(dlg,'edit','ymin        '); set(h(2),'String',min(sig{sig_num(1)}.Data));
    h=addblock(dlg,'edit','ymax        '); set(h(2),'String',max(sig{sig_num(1)}.Data));
    h=addblock(dlg,'button',{'Apply','OK','Cancel'});
   
    box_h = [];
    %Define callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
        if ishandle(box_h); delete(box_h); end
        values=probe(dlg);
        dlg_hc = get(dlg.Handle,'Children');
        hn=get(dlg_hc(12),'Value');
        limits = [sort([str2double(values(2)) str2double(values(3))]) sort([str2double(values(4)) str2double(values(5))])];
        figure(fighandles(hn));
        box_h(1) = line([limits(1) limits(2)],[limits(3) limits(3)],'Color','k','LineStyle','--','LineWidth',3);
        box_h(2) = line([limits(1) limits(2)],[limits(4) limits(4)],'Color','k','LineStyle','--','LineWidth',3);
        box_h(3) = line([limits(1) limits(1)],[limits(3) limits(4)],'Color','k','LineStyle','--','LineWidth',3);
        box_h(4) = line([limits(2) limits(2)],[limits(3) limits(4)],'Color','k','LineStyle','--','LineWidth',3);
        figure(dlg.Handle)
        
    end

    set(h(2),'Callback',@OKCallback);
    function OKCallback(varargin)
        if ishandle(box_h); delete(box_h); end
        values=probe(dlg);
        dlg_hc = get(dlg.Handle,'Children');
        hn=get(dlg_hc(12),'Value');
        limits = [sort([str2double(values(2)) str2double(values(3))]) sort([str2double(values(4)) str2double(values(5))])];
        if ishandle(box_h); delete(box_h); end
        figure(fighandles(hn));
        func(limits);
        %delete(dlg);
    end
    
    set(h(3),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        if ishandle(box_h); delete(box_h); end
        delete(dlg);
    end

    
    locate(dlg,'center');
    dlg.Hidden = false;
    
end




end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End SignalGUI



%% utilities

%Create SMASH dialog unless it already exists
function h=FindOrCreateDlg(src,name)
if isappdata(src,name)
    h=getappdata(src,name);
    if ishandle(h)
        figure(h)
        return
    end
end
h = SMASH.MUI.Dialog;
setappdata(src,name,h.Handle);
end


%% Signal plotting   
function plotdata(varargin)
    if (nargin < 3)
        error('Require (figure handle, signal object, signal numbers)')
    else
        fig = varargin{1};
        sig = varargin{2};
        sig_num = varargin{3};
        options = 'new plot';
    end
    if (nargin ==4); options = varargin{4}; end;
    
    %figure(fig);
    set(0,'CurrentFigure',fig);
    ha=gca;

    switch lower(options)
        case 'new plot'
            cla;

            if ~isempty(sig_num)
                legendentry = [];
                for i=1:length(sig_num)
                    %set(sig{sig_num(i)}.GraphicOptions,'LineWidth',1);                 
                    view(sig{sig_num(i)},ha);
                    legendentry{i}=strrep(sig{sig_num(i)}.Name,'_','\_');
                end
                lh = legend(legendentry,'Color','none','Location','Best','EdgeColor','w','LineWidth',1);
                legend('boxoff');
                %set(lh,'Box','off');
                xlabel(sig{sig_num(1)}.GridLabel);
                ylabel(sig{sig_num(1)}.DataLabel);
            end
           
            
        case 'overlay'    
            %Current signals in black
            for i=1:length(sig_num)
            [tempsigx tempsigy] = limit(sig{sig_num(i)});
            line(tempsigx, tempsigy,'Color',[0 0 0],'LineStyle','--','LineWidth',2);
            end  
            
      
        case 'overlay_all'
            
            %All signals in grey
            for i=1:numel(sig)
            [tempsigx tempsigy] = limit(sig{i});
            line(tempsigx, tempsigy,'Color',[0.75 0.75 0.75],'LineStyle','-.','LineWidth',2);
            end  

            
    end
end

%% Line colors initilization (modified from PointVISAR)
function color=DistinguishedLines(number)

map=[];
map = get(groot,'DefaultAxesColorOrder');

map(end+1,:)=[0.00 0.00 1.00]; % blue
map(end+1,:)=[0.00 0.50 0.00]; % green
map(end+1,:)=[1.00 0.00 0.00]; % red
map(end+1,:)=[0.00 0.75 0.75]; % cyan
map(end+1,:)=[0.90 0.00 0.90]; % magenta
map(end+1,:)=[0.75 0.75 0.00]; % yellowish
map(end+1,:)=[0.75 0.50 0.00]; %brown
map(end+1,:)=[0.50 0.50 0.50]; %grey
map(end+1,:)=[0.50 0.00 1.00]; %purple
map(end+1,:)=[1.00 0.00 0.50]; %pink
map=[map; 0.75*map]; % some darker variations

Ncolor=size(map,1);
while number>Ncolor
    number=number-Ncolor;
end
color=map(number,:);
end

%% Hugoniot material properties
function [rho c0 s g0 varargout] = getHugProp(varargin)

material = varargin{1};


switch material
    case 'DefinedSamples'
        rho = 1;
        c0 = 1;
        s = 1;
        g0 = 1; 
        material = {'Aluminum','Beryllium','Copper','Gold', ...
            'LiF','Lead','Molybdenum','Stainless Steel','Tantalum',...
            'Rhenium','Zirconium','Zirconium1','Zirconium2','Epoxy'};
        
      case 'DefinedWindows'
        rho = 1;
        c0 = 1;
        s = 1;
        g0 = 1; 
        material = {'Diamond','LiF','PMMA','Quartz','Sapphire'}; 
        
      case 'DefinedAll'
        rho = 1;
        c0 = 1;
        s = 1;
        g0 = 1; 
        material = {'Aluminum','Beryllium','Copper','Gold', 'Diamond', ...
            'LiF','Molybdenum','PMMA','Quartz','Sapphire', ...
            'Stainless Steel','Tantalum','Rhenium','Epoxy'};
        
    
    %% Metals
    case 'Aluminum'
        rho = 2.703;
        c0 = 5.35;
        s = 1.34;
        g0 = 2.14; 
        
    case 'Beryllium'
        rho = 1.851;
        c0 = 7.998;
        s = 1.124;
        g0 = 1.16;   
        
    case 'Copper'
        rho = 8.93;
        c0 = 3.94;
        s = 1.489;
        g0 = 1.99;
    
    case 'Gold'
        rho = 19.24;
        c0 = 3.056;
        s = 1.572;
        g0 = 2.97;
    
    case 'Lead'
        rho = 11.3463;
        c0 = 2.16895;
        s = 1.41186;
        g0 = 2.5;   
        
        
    case 'Molybdenum'
        rho = 10.215;
        c0 = 5.122;
        s = 1.256;
        g0 = 1.4;   
         
    case 'Stainless Steel'
        rho = 7.83;
        c0 = 4.4773;
        s = 1.4654;
        g0 = 1.5;   
        
    case 'Tantalum'
        rho = 16.656;
        c0 = 3.43;
        s = 1.19;
        g0 = 1.82;
   
    case 'Rhenium'
        rho = 21.02;
        c0 = 4.184;
        s = 1.367;
        g0 = 2.44;    
  
    case 'Zirconium'
        rho = 6.506;
        c0 = 3.89;
        s = 0.292;
        g0 = 0.93;  
        
    case 'Zirconium1'
        rho = 6.506;
        c0 = 3.757;
        s = 1.018;
        g0 = 1.09; 
        
    case 'Zirconium2'
        rho = 6.506;
        c0 = 3.296;
        s = 1.271;
        g0 = 1.09;   
        
    case 'Epoxy'
        rho = 1.107;
        c0 = 2.8;
        s = 1.7;
        g0 = 1.13;       
        
        
        
        
    %% Windows    
    case 'Diamond'
        rho = 3.52;
        c0 = 18022;
        s = 2*2.07;
        g0 = 1.5;
        
    case 'LiF'
        rho = 2.638;
        c0 = 5.148;
        s = 1.353;
        g0 = 1.63;
        
    case 'PMMA'
        rho = 1.1837;
        c0 = 2.598;
        s = 1.516;
        g0 = 1.5;
        
    case 'Quartz'
        rho = 2.65;
        c0 = 6.36;
        s = 2*1.36;
        g0 = 1.5;
        
    case 'Sapphire' %Linear, from Hayes
        rho = 3.985;
        c0 = 11.19;
        s = 1.0;
        g0 = 1.5; 
        

    otherwise
        disp('material not supported'); exit;
end
             uH=linspace(0,10,2000)';
             UsH=(c0)+(s).*uH;
             PH=(rho).*uH.*UsH;
             VH=(1-uH./UsH)./(rho);
 
             %Calculate gradient (P-V) of Hugoniot
             dpdvH = diff(PH)./diff(VH); dpdvH(end+1)=dpdvH(end);
%              PV = SMASH.SignalAnalysis.Signal(VH,PH);
%              dPV = differentiate(PV);
%              [V,dpdvH] = limit(dPV);
             %Relate to gradient of isentrope
             dpdvS = dpdvH.*(1-(rho).*(g0).*(1./(rho)-VH)./2)-PH.*(rho).*(g0)./2;
 
             %Calculate corresponding wavespeeds
             ce=sqrt(-VH.^2.*dpdvS);
             c = ce./((rho).*(VH));
             
             Iu = uH;
             Ic = c;
             
             varargout{1} = Iu;
             varargout{2} = Ic;
             varargout{3} = material;

end



