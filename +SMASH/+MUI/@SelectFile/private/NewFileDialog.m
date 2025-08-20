function [name,type]=NewFileDialog(source,object)


name='';
type='file';

%% create and display dialog
while true
    %
    dlg=SMASH.MUI.Dialog();
    dlg.Hidden=true;    
    dlg.Name='New file/directory';
    %
    Name=addblock(dlg,'edit','Name:',40);
    set(Name(2),'String',name);
    %
    Type=addblock(dlg,'check',{'File' 'Directory'},10);
    set(Type,'Callback',@setType);
    switch type
        case 'file'
            set(Type(1),'Value',1);
            set(Type(2),'Value',0);
        case 'directory'
            set(Type(1),'Value',0);
            set(Type(2),'Value',1);
            ebd
    end
    %
    Done=addblock(dlg,'button',{'OK' 'Done'},10);
    set(Done(1),'Callback',@OK);
    set(Done(2),'Callback',@cancel);
    %    
    locate(dlg,'center',source)
    dlg.Hidden=false;
    dlg.Modal=true;
    waitfor(dlg.Handle);
    %
    if isempty(name)
        return    
    end
    target=fullfile(object.StartDir,name);
    if exist(target,'file')==2
        choice=questdlg('File already exists--overwrite?','Overwrite file?',...
            'yes','no','no');
        if strcmpi(choice,'yes')
            return
        end
    elseif exist(target,'dir')==7
        errordlg('Directory cannot be created because it already exists','Directory error','modal');
    else
        return
    end
end

%% define callbacks
    function setType(src,varargin)
        set(Type,'Value',0);
        set(src,'Value',1);
    end

    function OK(varargin)
        name=get(Name(2),'String');
        if get(Type(1),'Value')
            type='file';
        elseif get(Type(2),'Value')
            type='directory';
        end           
        delete(dlg);
    end

    function cancel(varargin)
        name='';
        delete(dlg);
    end


end