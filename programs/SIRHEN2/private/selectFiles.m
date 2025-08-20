% This function selects multiple signal files.
%    list=selectFiles();
% The output "list" is a cell array of file import specifications: file
% name, file format, and record number.  These specifications can passed
% directly to the readFile function.
%
% See also SMASH.FileAccess.readFile
%

function specification=selectFiles(MainFigure)

specification={};

% create dialog box
setProgramFont()
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Select data files';

Directory=addblock(dlg,'edit_button',{'Current directory:',' Select '},40);

temp={' '};
temp=repmat(temp,[15 1]);
Contents=addblock(dlg,'listbox','Directory contents:',temp,40);

Selected=addblock(dlg,'custom',{'listbox' 'button'},{'Selected files:' 'Remove'},...
    [40 1],[],{repmat({' '},[5 1])});
set(Selected(2),'String',{});

Finish=addblock(dlg,'button',{' Done ' ' Cancel '});

%% define callbacks
set(Directory(2),'Callback',@changeDirectory);
    function changeDirectory(varargin)
        target=get(Directory(2),'String');        
        try
            current=pwd;
            cd(target);
            target=pwd;
            cd(current);
        catch
            target=get(Directory(2),'UserData');
        end
        set(Directory(2),'String',target,'UserData',target);                
        updateContents();
    end

set(Directory(3),'Callback',@selectDirectory)
    function selectDirectory(varargin)
        start=get(Directory(2),'String');
        target=uigetdir(start,'Select directory');
        if isnumeric(target)
            return
        else
            set(Directory(2),'String',target,'UserData',target);
            updateContents();
        end        
    end

set(Contents(2),'Callback',@selectFile,'ToolTipString','Double-click to select file/directory')
    function selectFile(varargin)
        selection=get(dlg.Handle,'SelectionType');
        fprintf('%s\n',selection);
        if ~strcmpi(selection,'open')
            return
        end
        target=get(Directory(2),'String');
        list=get(Contents(2),'String');
        value=get(Contents(2),'Value');
        target=fullfile(target,list{value});
        if exist(target,'dir')==7
            current=pwd;
            cd(target);
            target=pwd;
            cd(current);
            set(Directory(2),'String',target,'UserData',target);
            updateContents();
            return
        end
        try
            SMASH.Graphics.FigureTools.focus('off');
            pause(0.1);            
            format=SMASH.FileAccess.determineFormat(target);
            SMASH.Graphics.FigureTools.focus('on');
        catch
            return
        end
        current=get(Selected(end),'UserData');        
        [record,label]=selectRecord(target,format);       
        if isempty(record)
            return
        end
        current{end+1}={target format record};                                
        set(Selected(end),'UserData',current);
        [~,name,ext]=fileparts(target);
        if ischar(label)
            entry=sprintf('%s, %s',[name ext],label);
        elseif isnumeric(label) && ~isempty(label)
            entry=sprintf('%s, (%g)',[name ext],label);
        else
            entry=sprintf('%s',[name ext]);
        end
        list=get(Selected(2),'String');
        if isempty(list)
            list={entry};
        else
            list{end+1}=entry;
        end
        set(Selected(2),'String',list);
    end

set(Selected(3),'Callback',@remove);
    function remove(varargin)
        label=get(Selected(2),'String');
        if isempty(label)
            return
        end
        index=get(Selected(2),'Value');           
        data=get(Selected(end),'UserData');        
        label=label([1:index-1 index+1:end]);
        data=data([1:index-1 index+1:end]);
        if index > 1
            index=index-1;
        end
        set(Selected(2),'String',label,'UserData',data,'Value',index);        
    end

set(Finish(1),'Callback',@done);
    function done(varargin)
        specification=get(Selected(end),'UserData');   
        delete(dlg);
    end

set(Finish(2),'Callback',@cancel);
    function cancel(varargin)
        delete(dlg);
    end

% helper functions
    function updateContents()
        target=get(Directory(2),'String');
        file=dir(target);
        N=numel(file);
        list={};
        for n=1:N                       
            if file(n).isdir
                if strcmp(file(n).name,'.')
                    continue
                end
                list{end+1}=sprintf('%s%s',file(n).name,filesep); %#ok<AGROW>
            elseif ~(file(n).name(1) == '.')
                list{end+1}=file(n).name; %#ok<AGROW>
            end
        end
        value=get(Contents(2),'Value');
        value=min(value,numel(list));
        set(Contents(2),'Value',value,'String',list);
    end

% finalize and display dialog box
set(Directory(2),'String',pwd,'UserData',pwd);
updateContents();

locate(dlg,'center');
SMASH.Graphics.FigureTools.focus(dlg.Handle);
return2main=onCleanup(@() figure(MainFigure));
dlg.Hidden=false;

uiwait(dlg.Handle);

end

function [record,label]=selectRecord(target,format)

switch format
    case 'sda'
        object=SMASH.FileAccess.SDAfile(target);
        record=probe(object);
        N=numel(record);
        label=record;
    case 'pff'
        object=SMASH.FileAccess.PFFfile(target);
        report=probe(object);
        N=numel(report);
        record=cell(1,N);
        label=cell(1,N);
        for n=1:N
            record{n}=n;
            label{n}=report(n).Title;
        end
    case 'column'        
        record=[1 2];
        label='';
        return
    case 'thriftysignal'
        record=1;
        label=[];
        return
     case 'taf'
         record=1;
         label={};
         return
    otherwise
        object=SMASH.FileAccess.DigitizerFile(target,format);        
        report=probe(object);
        N=report.NumberSignals;
        record=cell(1,N);
        label=cell(1,N);
        for n=1:N
            record{n}=n;
            try
                label{n}=report.Name{n};           
            catch
            end
        end                      
end

if N > 1    
    OldFocus=SMASH.Graphics.FigureTools.focus();
    CU=onCleanup(@() SMASH.Graphics.FigureTools.focus(OldFocus));
    SMASH.Graphics.FigureTools.focus('off');
    selection=listdlg('ListString',label,...
        'PromptString','Select file record','Name','Select record',...
        'SelectionMode','single');
    if isempty(selection)
        record=1;
        label='taf';
        return
    end
    record=record{selection};
    label=label{selection};
else
    record=record{1};
    label=label{1};
end

end