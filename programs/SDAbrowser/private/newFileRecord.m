function new=newFileRecord(archive)

new='';
% create dialog box
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='New variable record';

File=addblock(dlg,'edit_button',{'File name:' ' Select '},40);
set(File(2),'UserData','','Callback',@setFile);
set(File(3),'Callback',@selectFile);

Label=addblock(dlg,'edit','Label:',40);
set(Label(2),'Enable','off');

Description=addblock(dlg,'medit','Description:',40,5);

deflate=cell(10,1);
for k=1:10
    switch k-1
        case 0
            deflate{k}=sprintf('%d (none)',k-1);
        case 9
            deflate{k}=sprintf('%d (max)',k-1);
        otherwise
            deflate{k}=sprintf('%d',k-1);
    end
end
Deflate=addblock(dlg,'popup','Deflate setting:',deflate);

Action=addblock(dlg,'button',{'Done','Cancel'});
set(Action(1),'Callback',@ok);
set(Action(2),'Callback',@cancel);

% set up callbacks
    function setFile(varargin)
        filename=get(File(2),'String');
        if exist(filename,'file')~=2
            errordlg('Requested file does not exist','Invalid file','modal');            
            set(File(2),'String',get(File(2),'UserData'));
            return
        end
        [pathname,~,~]=fileparts(filename);
        start=pwd;
        cd(pathname);
        pathname=pwd;
        cd(start);
        filename=fullfile(pathname,filename);
        set(File(2),'UserData',filename);
        [~,short,ext]=fileparts(filename);
        set(Label(2),'String',[short ext]);        
    end
    function selectFile(varargin)
        [filename,pathname]=uigetfile('*.*','Select file');
        if isnumeric(filename)
            return
        end
        filename=fullfile(pathname,filename);
        set(File(2),'String',filename,'UserData',filename);
        [~,short,ext]=fileparts(filename);
        set(Label(2),'String',[short ext]);
    end   

    function ok(varargin)
        filename=get(File(2),'String');        
        new=get(Label(2),'String');
        description=get(Description(2),'String');
        deflate=get(Deflate(2),'Value')-1;
        import(archive,filename,description,deflate);
        delete(dlg);
    end
    function cancel(varargin)
        delete(dlg);
    end

% finish and show dialog box
locate(dlg,'center');
dlg.Modal=true;
dlg.Hidden=false;

uiwait(dlg.Handle);

end