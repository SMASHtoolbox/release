% launch Launch graphical interface
%
% This method launches a graphical interface for selecting files and
% directories.
%    file=launch(object);
% This interface is a modal dialog that stops execution until the user
% clicks on the "OK" or "Cancel" buttons.  In single selection mode, the
% output "file" is the name of the selected file/directory; in
% multiple selection mode, the output is a cell array of file/directory
% names.  Pressing the "Cancel" button causes this output to be zero.
%
% See also SelectFile
%

%
% created November 3, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function file=launch(object)

%% create dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name=object.Title;

Directory=addblock(dlg,'popup_button',...
    {'Current directory:' 'Recent' 'Refresh'},{''},30);
set(Directory(2),'Callback',@changeDirectory);
set(Directory(3),'Callback',@showRecent);
set(Directory(4),'Callback',@(varargin) refreshDirectory);
%gap=addblock(dlg,'text',' ');
%delete(gap);

group={};
if strcmpi(object.FilterControl,'on')
    Filter=addblock(dlg,'edit_check',{'Filter:' 'Enable'},30);
    set(Filter(2),'Callback',@changeFilter,'String',object.Filter);
    set(Filter(3),'Callback',@enableFilter);
    if strcmpi(object.EnableFilter,'on')
        set(Filter(3),'Value',1);
    end
    group=[group Filter];
end

File=addblock(dlg,'listbox',object.FileLabel,{''},50,10);
set(File(2),'Callback',@selectFile);
group=[group File];

if strcmpi(object.HiddenControl,'on')
    Hidden=addblock(dlg,'check','Show hidden files');
    set(Hidden,'Callback',@changeHidden);
    group=[group Hidden];    
end

FileButton=addblock(dlg,'button',{'New' 'Delete' 'Rename' ''},10);
group=[group FileButton];
box(dlg,group);
if strcmpi(object.FileControls,'on')
    delete(FileButton(end));
    set(FileButton(1),'Callback',@newFile);
    set(FileButton(2),'Callback',@deleteFile);
    set(FileButton(3),'Callback',@renameFile);
else
    delete(FileButton);
end

if object.MultipleSelection
    %gap=addblock(dlg,'text',' ');
    %delete(gap);    
    SelectedFiles=addblock(dlg,'listbox','Selected files:',{''},50,5);
    set(SelectedFiles(2),'UserData',{});
    SelectedOptions=addblock(dlg,'check',{'Show full path' 'Remove duplicates'});
    set(SelectedOptions,'Callback',@refreshSelected);
    SelectedButton=addblock(dlg,'button',...
        {'Add' 'Remove' 'Move up' 'Move down'},10);
    set(File(2),'Max',2);   
    box(dlg,[SelectedFiles SelectedOptions SelectedButton]);
    set(SelectedButton(1),'Callback',@addFile);   
    set(SelectedButton(2),'Callback',@removeFile);
    set(SelectedButton(3),'Callback',@promoteFile);
    set(SelectedButton(4),'Callback',@demoteFile);
    set(SelectedOptions(2),'Value',1);
else
    set(File(2),'Max',1);
end

%gap=addblock(dlg,'text',' ');
%delete(gap);
Done=addblock(dlg,'button',{'OK' 'Cancel'},10);
set(Done(1),'Callback',@OK);
set(Done(2),'Callback',@Cancel);

%% finish and reveal dialog
file=0;

if isempty(object.StartDir)
    object.StartDir=pwd;
end
persistent Recent
if isempty(Recent)
    Recent{1}=object.StartDir;
end
enableFilter();
refreshDirectory()

if isempty(object.Reference)
    try
        origin=groot;
    catch
        origin=0;
    end
else
    origin=object.Reference;
end
locate(dlg,object.Location,origin);
dlg.Hidden=false;
dlg.Modal=true;

try
    waitfor(dlg.Handle);
catch
    delete(dlg);
end

%% define callbacks
    function changeDirectory(varargin)
        old=get(Directory(2),'UserData');
        new=get(Directory(2),'Value');
        if new==old
            return
        end
        target=object.StartDir;
        for n=1:(old-new)
            target=fileparts(target);
        end
        object.StartDir=target;
        refreshDirectory();
    end
    function showRecent(varargin)
        pos=get(dlg.Handle,'Position');
        selection=listdlg('ListString',Recent,'SelectionMode','single',...
            'Name','Select recent','PromptString','Select recent directory:',...
            'ListSize',pos(3:4));
        if isempty(selection)
            return
        end
        object.StartDir=Recent{selection};
        refreshDirectory();
    end
    function changeFilter(varargin)
         refreshDirectory();
    end
    function enableFilter(varargin)
        if get(Filter(3),'Value')
            set(Filter(2),'Enable','on');
        else
            set(Filter(2),'Enable','off');
        end
        refreshDirectory();
    end
    function selectFile(varargin)
        if strcmp(get(dlg.Handle,'SelectionType'),'open')
            % 
        else
            return
        end
        value=get(File(2),'Value');
        label=get(File(2),'String');
        label=label{value};
        if label(end)==filesep
            object.StartDir=fullfile(object.StartDir,label(1:end-1));
            refreshDirectory;
        end
    end
    function changeHidden(varargin)
        if get(Hidden,'Value')
            object.ShowHidden=true;
        else
            object.ShowHidden=false;
        end
        refreshDirectory();
    end
    function newFile(varargin)
        [name,type]=NewFileDialog(dlg.Handle,object);
        if isempty(name)
            return
        end                   
        switch type
            case 'file'
                if isa(object.NewFunction,'function_handle')
                    try
                        object.NewFunction(name);
                    catch
                        return
                    end
                else
                    fid=fopen(name,'w');
                    fclose(fid);
                end
            case 'directory'
                mkdir(fullfile(object.StartDir,name));
        end
        refreshDirectory();
    end
    function deleteFile(varargin)
        value=get(File(2),'Value');
        list=get(File(2),'String');        
        target=fullfile(object.StartDir,list{value});
        if exist(target,'file')
            message=sprintf('Delete file "%s"?',list{value});
            choice=questdlg(message,'Delete file?','yes','no','no');
            if strcmpi(choice,'no')
                return
            end
            if isa(object.DeleteFunction,'function_handle')
                try
                    object.DeleteFunction(target);
                catch
                    return
                end
            else
                delete(target);
            end
        elseif exist(target,'dir')
            message=sprintf('Delete directory "%s"?',list{value});
            choice=questdlg(message,'Delete directory?','yes','no','no');
            if strcmpi(choice,'no')
                return
            end
            rmdir(target,'s');
        end
        refreshDirectory();
    end
    function renameFile(varargin)
        value=get(File(2),'Value');
        list=get(File(2),'String');
        target=fullfile(object.StartDir,list{value});
        if exist(target,'file')
            message=sprintf('New name for file "%s"',list{value});
            label='Rename file';
        elseif exist(target,'dir')
            message=sprintf('New name for directory "%s"',list{value});
            label='Rename directory';
        end
        choice=inputdlg(message,label);
        if isempty(choice)
            return
        end
        new=fullfile(object.StartDir,strtrim(choice{1}));
        if (exist(new,'file')==2) || (exist(new,'dir')==7)
            h=errordlg('New file/directory name already in use',...
                'Rename error','modal');
            waitfor(h);
            renameFile();
        end
        try
            movefile(target,new)
        catch
            h=errordlg('Unable to rename file/directory',...
                'Rename error','modal');
            waitfor(h);
            return
        end
        refreshDirectory();
    end
    function addFile(varargin)
        selected=get(SelectedFiles(2),'UserData');
        list=get(File(2),'String');
        value=get(File(2),'Value');
        for m=1:numel(value)
            selected{end+1}=fullfile(object.StartDir,list{value(m)}); %#ok<AGROW>
        end
        set(SelectedFiles(2),'UserData',selected);
        refreshSelected();
    end
    function removeFile(varargin)
        selected=get(SelectedFiles(2),'UserData');
        value=get(SelectedFiles(2),'Value');
        selected=selected([1:value-1 value+1:end]);
        set(SelectedFiles(2),'UserData',selected);
        refreshSelected();
    end
    function promoteFile(varargin)
        selected=get(SelectedFiles(2),'UserData');
        value=get(SelectedFiles(2),'Value');
        if value==1
            return
        end
        temp=selected{value-1};
        selected{value-1}=selected{value};
        selected{value}=temp;
        set(SelectedFiles(2),'UserData',selected,'Value',value-1);
        refreshSelected();
    end
    function demoteFile(varargin)
        selected=get(SelectedFiles(2),'UserData');
        value=get(SelectedFiles(2),'Value');
        if value==numel(selected)
            return
        end
        temp=selected{value+1};
        selected{value+1}=selected{value};
        selected{value}=temp;
        set(SelectedFiles(2),'UserData',selected,'Value',value+1);
        refreshSelected();
    end
    function OK(varargin)
        if object.MultipleSelection
            file=refreshSelected();
            for n=1:numel(file)
                addRecent(file{n});
            end
        else
            value=get(File(2),'Value');
            list=get(File(2),'String');
            if isempty(list)
                % do nothing
            else
                file=fullfile(object.StartDir,list{value});
                addRecent(object.StartDir);
            end
        end
        delete(dlg);
    end
    function Cancel(varargin)
        delete(dlg);
    end

%% define helper functions
    function refreshDirectory()
        %
        label={};
        old=object.StartDir;
        while true
            [new,temp]=fileparts(old);
            if strcmpi(new,old)                
                label{end+1}=new; %#ok<AGROW>
                break
            else
                label{end+1}=[temp filesep]; %#ok<AGROW>
                old=new;
            end
        end
        set(Directory(2),'String',label(end:-1:1),...
            'Value',numel(label),'UserData',numel(label));
        %
        if get(Filter(3),'Value')
            label=scanDirectory(object.StartDir,...
                get(Filter(2),'String'),object.ShowHidden);
        else
            label=scanDirectory(object.StartDir,...
                '',object.ShowHidden);
        end         
        set(File(2),'String',label,'Value',1);
    end
    function addRecent(new)
        if exist(new,'file')
            new=fileparts(new);
        end
        for n=1:numel(Recent)
            if strcmp(new,Recent{n})
                Recent{n}=Recent{1};
                Recent{1}=new;
                return
            end
        end
        Recent(2:end+1)=Recent;
        Recent{1}=new;
    end
    function selected=refreshSelected(varargin)
        selected=get(SelectedFiles(2),'UserData');
        if get(SelectedOptions(2),'Value') % remove duplicates
            N=numel(selected);
            keep=true(N,1);
            for m=1:N
                for n=1:(m-1)
                    if strcmp(selected{m},selected{n})
                        keep(m)=false;
                        break
                    end
                end
            end
            selected=selected(keep);
        end
       N=numel(selected);
       if N==0
           set(SelectedFiles(2),'String','','Value',[]);
           return
       end       
       label=cell(N,1);
       for m=1:N
           if get(SelectedOptions(1),'Value') % show full path
               label{m}=selected{m};
           else
               [temp,filename,ext]=fileparts(selected{m});               
               label{m}=[filename ext];
               if isempty(label{m})
                   [~,filename]=fileparts(temp);
                   label{m}=[filename filesep];
               end
           end
       end
       value=get(SelectedFiles(2),'Value');       
       if isempty(value)
           value=1;
       end
       value=min(value,numel(label));
       set(SelectedFiles(2),'String',label,'Value',value);
    end
end