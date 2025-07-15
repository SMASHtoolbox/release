function new=newVariableRecord(archive)

new='';
% verify that data exists
vars=evalin('base','whos');
if isempty(vars)
    warndlg('No variables found in the base workspace','Empty workspace');
    return;
else
    N=numel(vars);
    VariableName=cell(N,1);
    for k=1:N
        VariableName{k}=vars(k).name;
    end    
end

% create dialog box
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='New variable record';

Variable=addblock(dlg,'popup','Variable name:',VariableName,40);

Label=addblock(dlg,'edit','Label (required):',40);
set(Label(2),'UserData','','Callback',@setLabel);

Description=addblock(dlg,'medit','Description (optional):',40,5);

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
    function setLabel(varargin)
        new=get(Label(2),'String');
        new=strtrim(new);
        current=probe(archive);        
        for n=1:numel(current)
           if strcmp(new,current{n})
               message{1}='This label is already in use';
               message{2}='Please choose something else';
               errordlg(message,'Duplicate label','modal');
               set(Label(2),'String',get(Label(2),'UserData'));
               return
           end
        end
        set(Label(2),'UserData',new);
    end

    function ok(varargin)
        value=get(Variable(2),'Value');
        if isempty(value)
            return       
        end
        variable=get(Variable(2),'String');        
        variable=variable{value};
        variable=evalin('base',variable);
        new=get(Label(2),'String');
        slash=(new == '/') | (new == '\');
        new(slash)='_';
        description=get(Description(2),'String');
        deflate=get(Deflate(2),'Value')-1;
        insert(archive,new,variable,description,deflate);
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