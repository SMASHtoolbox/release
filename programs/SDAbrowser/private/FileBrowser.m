function ArchiveFile=FileBrowser()

% create dialog box
dlg=SMASH.MUI.Dialog('FontSize',12);
dlg.Hidden=true;
dlg.Name='Select SDA file';

Directory=addblock(dlg,'edit_button',{'Current directory:',' Select '},40);

temp={' '};
temp=repmat(temp,[15 1]);
Contents=addblock(dlg,'listbox','Directory contents:',temp,40);
set(Contents(end),'TooltipString',...
    'Double-click to select, right-click for more options');

Hidden=addblock(dlg,'check','Show hidden files');

File=addblock(dlg,'button',{'New archive file' 'Delete archive file'});

Finish=addblock(dlg,'button',{' Done ' ' Cancel '});

% define callbacks
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

set(Contents(2),'Callback',@selectFile)
    function selectFile(varargin)
        selection=get(dlg.Handle,'SelectionType');
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
        else
            done();
        end
    end

set(Hidden,'Callback',@changeHidden)
    function changeHidden(varargin)
        updateContents();
    end

set(File(1),'Callback',@newFile)
    function newFile(varargin)
        value=inputdlg('Archive file name:','New archive',[1 40]);
        if isempty(value)
            return       
        end  
        value=value{1};
        [~,~,ext]=fileparts(value);
        if ~strcmpi(ext,'.sda')
            value=[value '.sda'];
        end
        target=get(Directory(2),'String');
        target=fullfile(target,value);
        if exist(target,'file')
            errordlg('Archive file name is already in use','Invalid name');
            return
        end
        try
            SMASH.FileAccess.SDAfile(target);
        catch
            errordlg('Unable to create requested archive file','File error');
            return
        end
        updateContents;
    end

set(File(2),'Callback',@deleteFile)
    function deleteFile(varargin)
        target=get(Directory(2),'String');
        list=get(Contents(2),'String');
        value=get(Contents(2),'Value');
        target=fullfile(target,list{value});
        if SMASH.FileAccess.SDAfile.isWritable(target)
            message=sprintf('Delete archive "%s"?',list{value});
            answer=questdlg(message,'Delete archive','yes','no','no');
            answer=strtrim(answer);
            if strcmpi(answer,'yes')
                delete(target);
                updateContents;
            end
        else
            errordlg('This archive cannot be deleted (not writable)','Delete error');
        end
    end

set(Finish(1),'Callback',@done);
    function done(varargin)
        list=get(Contents(2),'String');
        value=get(Contents(2),'Value');
        name=list{value};
        [~,~,ext]=fileparts(name);
        if ~strcmpi(ext,'.sda')                    
            errordlg('No archive file selected','No selection');
            return
        end        
        target=get(Directory(2),'String');
        ArchiveFile=fullfile(target,name);        
        delete(dlg);
    end

set(Finish(2),'Callback',@cancel);
    function cancel(varargin)
        delete(dlg);
    end

% helper functions
    function updateContents()
        hidden=~get(Hidden,'Value');
        target=get(Directory(2),'String');
        file=dir(target);
        N=numel(file);
        list={};
        for n=1:N
            if hidden && file(n).name(1)=='.'
                switch file(n).name
                    case {'.' '..'}
                        % show these directories
                    otherwise
                        continue
                end
            end
            if file(n).isdir
                list{end+1}=sprintf('%s%s',file(n).name,filesep); %#ok<AGROW>
            else
                [~,~,ext]=fileparts(file(n).name);
                if strcmpi(ext,'.sda')
                    list{end+1}=file(n).name; %#ok<AGROW>
                end
            end
        end
        value=get(Contents(2),'Value');
        value=min(value,numel(list));
        set(Contents(2),'Value',value,'String',list);
    end

% finalize and display dialog box
set(Directory(2),'String',pwd,'UserData',pwd);
updateContents();

ArchiveFile='';

locate(dlg,'center');
dlg.Modal=true;
dlg.Hidden=false;

uiwait(dlg.Handle);

end