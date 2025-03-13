% UNDER CONSTRUCTION
function createDialog(filename)

%% create dialog and archive objects
object=SMASH.MUI.Dialog('FontSize',12);
object.Hidden=true;

archive=SMASH.FileAccess.SDAfile(filename);
object.Name='SDA browser';

%% menu items
hmenu=uimenu('Label','File');
uimenu(hmenu,'Label','Select archive','Callback',@loadArchive);
     function loadArchive(varargin)
         filename=FileBrowser;
         if isempty(filename)
             return
         end
         archive=SMASH.FileAccess.SDAfile(filename);
         updateTitle();
         selectRecord();
     end
%uimenu(hmenu,'Label','Split archive','Separator','on','Enable','off');
uimenu(hmenu,'Label','Exit','Separator','on','Callback',@done);
    function done(varargin)
        delete(object);
    end

hmenu=uimenu('Label','Record');
InsertNew=uimenu(hmenu,'Label','Insert variable','Callback',@insertRecord);
    function insertRecord(varargin)
        if ~get(Writable,'Value')
            errordlg('This archive is not writable','Cannot write','modal');            
            return
        end
        new=newVariableRecord(archive);                
        updateTitle();
        label=probe(archive);
        for value=1:numel(label)
            if strcmp(new,label{value})
                break
            end
        end
        set(Record(2),'Value',value);
        selectRecord();
    end

ImportNew=uimenu(hmenu,'Label','Import file','Callback',@importRecord);
    function importRecord(varargin)
        if ~get(Writable,'Value')
            errordlg('This archive is not writable','Cannot write','modal');
            return
        end
        new=newFileRecord(archive);                
        updateTitle();
        label=probe(archive);
        for value=1:numel(label)
            if strcmp(new,label{value})
                break
            end
        end
        set(Record(2),'Value',value);
        selectRecord();
    end

Delete=uimenu(hmenu,'Label','Remove record','Separator','on');
set(Delete,'Callback',@removeRecord);
    function removeRecord(varargin)
        label=probe(archive);
        if numel(label) < 1
            return;
        end
        value=get(Record(2),'Value');
        label=label{value};
        message{1}=sprintf('Remove record "%s"?',label);
        message{2}='WARNING: this process may be slow and is irreversible';
        answer=questdlg(message,'Remove record?',' Yes ',' No ',' No ');
        if strcmpi(strtrim(answer),'yes')            
            remove(archive,label);
            updateTitle();
            selectRecord();
        end
    end

hmenu=uimenu('Label','Help');
uimenu(hmenu,'Label','About archive files','Callback',@aboutSDA);
    function aboutSDA(varargin)
        fig=getappdata(object.Handle,'HelpWindow');
        if ishandle(fig)
            figure(fig)
            return
        end              
        message=[...
            'Sandia Data Archive (SDA) files store data as binary records with a unique text label. ' ...
            'Based on the HDF5 format, each data record holds one MATLAB variable (array, structure, object, etc.), with nesting permitted. ' ...
            'Data records are inserted from MATLAB into the archive and extracted from the archive back into MATLAB. ' ...
            'An optional description may be associated with each record to document its contents. ' ...
            'Lossless compression (deflation) is also supported. '...
            %'\' ...
            %'Text and binary files of any type may also be imported into a data archive.  These files can exported to their original content/format.' ...
            ];
        fig=helpdlg(message,'About SDA');
        setappdata(object.Handle,'HelpWindow',fig);   
    end

%% archive blocks   
Title=addblock(object,'text',cell(3,1),50);

Writable=addblock(object,'checkbox','Writable');
set(Writable,'Callback',@setWritable);
    function setWritable(varargin)
        if get(Writable,'Value')
            archive.Writable='yes';
        else
            archive.Writable='no';
        end
    end

box(object,[Title Writable]);

    function updateTitle()
        [~,name,ext]=fileparts(archive.ArchiveFile);
        ArchiveTitle{1}=sprintf('Archive file "%s":',[name ext]);
        [label,type,~,status]=probe(archive);
        ArchiveTitle{2}=sprintf('   -contains %d record(s) and uses SDA version %s',...
            numel(label),status.FormatVersion);
        ArchiveTitle{3}=sprintf('   -was created %s and updated %s',...
            status.Created,status.Updated);
        set(Title,'String',ArchiveTitle);
        if strcmpi(status.Writable,'yes')
            set(Writable,'Value',1,'Enable','on');
        else
            set(Writable,'Value',0,'Enable','on');
        end
        try
            if strcmpi(type{1},'split');
                set(Writable,'Enable','off');
            else
                set(Writable,'Enable','on');
            end
        catch
        end
    end
updateTitle();

%% existing record blocks
gap=addblock(object,'text',' ');
delete(gap);
Record=addblock(object,'popup','Archive record(s):',{' '},50);
set(Record(2),'Callback',@selectRecord)
gap=addblock(object,'text',' ');
delete(gap);

addblock(object,'text','Record type: ',50);
Type=addblock(object,'text','Record type: ',50);

Description=addblock(object,'medit','Record description:',50,2);
set(Description(2),'Callback',@updateDescription);
    function updateDescription(varargin)
        value=get(Record(2),'Value');
        label=get(Record(2),'String');
        description=get(Description(2),'String');
        describe(archive,label{value},description);        
        %label=sprintf('/%s',label{value});
        %h5writeatt(archive.ArchiveFile,label,'Description',description);
    end

RecordButton=addblock(object,'button',...
    {' ' ' '},15);

    function selectRecord(varargin)       
        %
        [label,type,description]=probe(archive);
        if numel(label) > 0
            %
            value=get(Record(2),'Value');
            if value > numel(label)
                value=numel(label);
                set(Record(2),'Value',value)
            end                        
            set(Record(2),'String',label,'Enable','on');
            type=type{value};            
            set([InsertNew ImportNew Delete],'Enable','on');
            set(Description(2),'Enable','on');
            set(RecordButton(1),'Visible','on',...
                'String','Extract','Callback',@extractRecord);
            set(RecordButton(2),'Visible','off');
            set(Description(2),'String',description{value},'Enable','on');
            switch lower(type)
                case 'object'
                    try
                        source=h5readatt(archive.ArchiveFile,...
                            ['/' label{value}],'Class');
                    catch
                        source=h5readatt(archive.ArchiveFile,...
                            ['/' label{value}],'ClassName');
                    end
                    type=sprintf('%s (%s)',type,source);
                    set(Type,'String',type);
                    if ismethod(source,'view') && logical(exist(source,'class'))                        
                        set(RecordButton(2),'String','View','Visible','on',...
                            'Callback',@viewRecord);
                    end
                case 'file'
                    set(RecordButton(1),'String','Export',...
                        'Callback',@exportRecord);  
                    set(RecordButton(2),'Visible','off');  
                case 'split'
                    set([InsertNew ImportNew Delete],'Enable','off');
                    set(RecordButton(1),'String','Restore',...
                        'Callback',@restoreFile);  
                    set(Description(2),'Enable','off');                

            end            
            set(Type,'String',sprintf('   %s',type));                   
        else
            set(Record(2),'String',' ','Enable','off');
            set(Type,'String',' ');
            set(Description(2),'String','','Enable','off');
            set(RecordButton,'Visible','off');
        end
    end
selectRecord;

    function viewRecord(varargin)
        value=get(Record(2),'Value');
        label=get(Record(2),'String');
        previous=extract(archive,label{value});
        view(previous);
    end

    function extractRecord(varargin)
        answer=inputdlg({'Variable name for extracted record'},...
            'Choose variable',[1 40],{'previous'});       
        if isempty(answer)
            return
        elseif ~isvarname(answer{1})
            errordlg('Invalid variable name','Invalid name','modal')
            extractRecord();
        end        
        value=get(Record(2),'Value');
        label=get(Record(2),'String');
        previous=extract(archive,label{value});
        assignin('base',answer{1},previous);
    end

    function exportRecord(varargin)
        value=get(Record(2),'Value');
        label=get(Record(2),'String');
        target=fullfile(pwd,label{value});
        [~,~,ext]=fileparts(target);
        [filename,pathname]=uiputfile(ext,'Select export file',target);
        if isnumeric(filename)
            return
        end
        export(archive,label{value},fullfile(pathname,filename));
    end

    function restoreFile(varargin)
        SMASH.FileAccess.mergeSplits(archive.ArchiveFile);
    end

%% display dialog
set(object.Handle,'HandleVisibility','callback');
locate(object,'center');
object.Hidden=false;

end