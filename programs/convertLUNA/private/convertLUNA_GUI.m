function convertLUNA_GUI()

% determine if GUI already exists
fig=findobj(0,'Type','figure','Tag','convertLUNA_GUI');
if ishandle(fig);
    figure(fig);
    return
end

% internal settings
setting=struct();
setting.Source='';
setting.NumberFiles=[];
setting.FileList={};
setting.TimeStep={};
setting.TimeRange={};
setting.Target='';

% create GUI
main=SMASH.MUI.Dialog;
main.Hidden=true;
main.Name='Convert LUNA scans';
set(main.Handle,'Tag','convertLUNA_GUI');

dummy='refresh';
minwidth=40;

hSource=addblock(main,'edit_button',{'Source directory:',dummy},minwidth);
set(hSource(2),'Callback',@refreshFiles);
set(hSource(end),'String','Select','Callback',@selectSource);
    function selectSource(varargin)
        source=uigetdir(pwd,'Select source directory');
        if isnumeric(source)
            return
        end
        set(hSource(2),'String',source);
        refreshFiles;
    end

hFile=addblock(main,'popup_button',{'Source files:',dummy},{'(empty)'},minwidth);
set(hFile(end),'String','Refresh','Callback',@refreshFiles);
    function refreshFiles(varargin)
        source=get(hSource(2),'String');
        if isempty(source)
            return;
        end
        file=dir(fullfile(source,'*.obr'));
        if isempty(file)
            set(hFile(1),'String','Source files:');
            set(hFile(2),'String','(empty)');
            setting.FileList={};
            setting.Source='';
        else
            N=numel(file);
            setting.FileList=cell(1,N);
            for n=1:N
                setting.FileList{n}=file(n).name;
            end
            set(hFile(1),'String',sprintf('Source files (%d found):',N));
            set(hFile(2),'String',setting.FileList);
            setting.Source=source;
            setting.TimeStep=repmat({[]},[1 N]);
            setting.TimeRange=repmat({[]},[1 N]);
            setting.NumberFiles=N;
        end
    end

h=addblock(main,'button',{'Modify current','Modify all','View current'});
set(h(1),'Callback',@modifyCurrent);
    function modifyCurrent(varargin)
        if isempty(setting.Source)
            return
        end
        current=get(hFile(2),'Value');
        sub=SMASH.MUI.Dialog;
        sub.Hidden=true;
        sub.Name='Modify settings';
        h=addblock(sub,'edit','Current file:',...
            numel(setting.FileList{current}));
        set(h(1),'FontWeight','bold');
        set(h(end),'Style','text','String',setting.FileList{current});
        parent=get(h(end),'Parent');
        set(h(end),'BackgroundColor',get(parent,'Color'));
        hStep=addblock(sub,'edit','Time step (ns):',20);
        set(hStep(1),'FontWeight','bold');
        set(hStep(2),'String',sprintf('%.4f',setting.TimeStep{current}));
        hRange=addblock(sub,'edit','Time range (ns):',20);
        set(hRange(1),'FontWeight','bold');
        set(hRange(2),'String',sprintf('%.4f ',setting.TimeRange{current}));
        h=addblock(sub,'button',{'Done'});
        set(h(1),'Callback',@done)
        function done(varargin)
            entry=probe(sub);
            temp=sscanf(entry{1},'%g',1);
            if numel(temp)==1
                entry{1}=temp;
            elseif isempty(sscanf('%s',entry{1}))
                entry{1}=[];
            else
                set(hStep(2),'String','');
                return
            end
            temp=sscanf(entry{2},'%g',2);
            if numel(temp)==2
                entry{2}=temp;
            elseif isempty(sscanf('%s',entry{2}));
                entry{2}=[];
            else
                set(hRange(2),'String','');
                return
            end
            setting.TimeStep{current}=entry{1};
            setting.TimeRange{current}=entry{2};
            delete(sub);
        end
        h=findobj(sub.Handle,'Type','Text');
        set(h,'FontWeight','bold');
        locate(sub,'center',main.Handle);
        sub.Hidden=false;
        uiwait(sub.Handle);
    end
set(h(2),'Callback',@modifyAll);
    function modifyAll(varargin)
        if isempty(setting.Source)
            return
        end
        sub=SMASH.MUI.Dialog;
        sub.Hidden=true;
        sub.Name='Modify all settings';
        hStep=addblock(sub,'edit','Time step (ns):',20);
        set(hStep(1),'FontWeight','bold');
        hRange=addblock(sub,'edit','Time range (ns):',20);
        set(hRange(1),'FontWeight','bold');
        h=addblock(sub,'button',{'Done'});
        set(h(1),'Callback',@done)
        function done(varargin)
            entry=probe(sub);
            temp=sscanf(entry{1},'%g',1);
            if numel(temp)==1
                entry{1}=temp;
            elseif isempty(sscanf('%s',entry{1}))
                entry{1}=[];
            else
                set(hStep(2),'String','');
                return
            end
            temp=sscanf(entry{2},'%g',2);
            if numel(temp)==2
                entry{2}=temp;
            elseif isempty(sscanf('%s',entry{2}));
                entry{2}=[];
            else
                set(hRange(2),'String','');
                return
            end
            for k=1:setting.NumberFiles
                setting.TimeStep{k}=entry{1};
                setting.TimeRange{k}=entry{2};
            end
            delete(sub);
        end
        h=findobj(sub.Handle,'Type','Text');
        set(h,'FontWeight','bold');
        locate(sub,'center',main.Handle);
        sub.Hidden=false;
        uiwait(sub.Handle);
    end
set(h(3),'Callback',@viewCurrent);
    function viewCurrent(varargin)
        if isempty(setting.Source)
            return
        end
        current=get(hFile(2),'Value');
        target=fullfile(setting.Source,setting.FileList{current});
        object=SMASH.FileAccess.LUNA(target);
        step=setting.TimeStep{current};
        range=setting.TimeRange{current};
        if isempty(step) && isempty(range)
            % do nothing
        else
            object=modify(object,step,range);
        end
        view(object);
    end

hTarget=addblock(main,'edit_button',{'Target file:',dummy},minwidth);
set(hTarget(2),'Callback',@refreshTarget);
    function refreshTarget(varargin)
        setting.Target=get(hTarget(2),'String');
        [pathname,filename,extension]=fileparts(setting.Target);
        if ~strcmpi(extension,'.sda')
            extension=[extension '.sda'];
        end
        setting.Target=fullfile(pathname,[filename extension]);
        set(hTarget(2),'String',setting.Target);
        set(hTarget(end),'String','Select','Callback',@selectTarget);
    end
set(hTarget(3),'Callback',@selectTarget);
    function selectTarget(varargin)
        filespec={'*.sda;*.SDA','Sandia Data Archive files'};
        [filename,pathname]=uiputfile(filespec,'Select target file');
        if isnumeric(filename)
            return
        end
        [~,filename,extension]=fileparts(filename);
        if ~strcmpi(extension,'.sda')
            extension='.sda';
        end
        setting.Target=fullfile(pathname,[filename extension]);
        set(hTarget(2),'String',setting.Target);
    end

h=addblock(main,'button',{'Convert','Done'});
set(h(1),'Callback',@convertFiles)
    function convertFiles(varargin)
        if isempty(setting.Source)
            errordlg('No source directory specified','No source','modal');
            return
        elseif isempty(setting.Target)
            errordlg('No target file specified','No target','modal');
            return
        end
        convertLUNA(setting.Source,setting.Target,...
            setting.TimeStep,setting.TimeRange);
    end
set(h(2),'Callback','close(gcbf)');

% apply callback
%convertLUNA(source,target,step,range)

% format tweaks
h=findobj(main.Handle,'Style','text');
set(h,'FontWeight','bold');

%h=findobj(main.Handle,'Style','edit');
%set(h,'HorizontalAlignment','right');

% make dialog visible
locate(main,'center');
main.Hidden=false;
set(main.Handle,'HandleVisibility','callback');

end