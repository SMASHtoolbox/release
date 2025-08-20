% manage Manage region of interest array
%
% This method manages region of interest arrays.
%    object=manage(object);
% An interactive dialog box allows users to add, remove, promote, or demote
% array elements.  Existing elements can also be modified by calling the
% "select" method of the object class.
%
% Name/value pairs passed to this method:
%    object=manage(object,name,value,...);
% control the appearance and  behavior of the dialog box.
%    -'Target' specifies the axes where modifications are displayed
%    (defaults to the current axes).
%    -'Fixed' determines if the array can be changed (default value is
%    false).  Setting this value to true removes buttons for adding,
%    removing, promoting, and demoting array elements; existing elements
%    can still be modified.
%    -'Title' and 'FigureName' control the first line of text and figure
%    name of the dialog box.
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=manage(object,varargin)

% manage input
option.Target=[];
option.Fixed=false;
option.Title='Regions of interest:';
option.FigureName='Manage ROIs';
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    value=varargin{n+1};
    switch lower(name)
        case 'target'
            assert(all(ishandle(value)),'ERROR: invalid target handle');
            for m=1:numel(value)
                switch get(value(m),'Type')
                    case 'axes'
                        % do nothing
                    case 'figure'
                        value(m)=get(value(m),'CurrentAxes');
                    otherwise
                        value(m)=ancestor(value(m),'axes');
                end
            end
            option.Target=value;
        case 'fixed'
            if isnumeric(value)
                value=logical(value);
            end
            assert(islogical(value),'ERROR: invalid fixed value');
            option.Fixed=value;
        case 'title'
            assert(ischar(value) || isStringScalar(value),...
                'ERROR: invalid title');
            option.Title=value;
        case 'figurename'
            assert(ischar(value) || isStringScalar(value),...
                'ERROR: invalid figure name');
            option.FigureName=value;
        otherwise
            error('ERROR: invalid option "%s"',name);
    end
end

if isempty(option.Target)
    option.Target=gca();
end
option.Reference=ancestor(option.Target(1),'figure');

%
persistent legacy
if isempty(legacy)
    switch lower(SMASH.Graphics.checkGraphics())
        case 'java'
            legacy=true();
        case 'javascript'
            legacy=false();
    end
end
%legacy=true();

if legacy
    object=manageLegacy(object,option);
else
    object=manageCurrent(object,option);
end

end

function object=manageLegacy(object,option)

% create dialog box
dlg=SMASH.MUI.Dialog('FontSize',get(option.Target(1),'FontSize'));
dlg.Hidden=true;
dlg.Name=option.FigureName;

ROIlist=addblock(dlg,'listbox_button',{option.Title 'Modify'},{''},25,10);
updateList();
showSelection();
set(ROIlist(2),'Callback',@showSelection);
    function showSelection(varargin)
        wipe(object,option.Target);
        index=get(ROIlist(2),'Value');
        if index <= numel(object)
            view(object(index),option.Target);
        end
    end
set(ROIlist(3),'Callback',@modifyButton);
    function modifyButton(varargin)
        if isempty(object)
            return
        end
        h=findall(dlg.Handle,'Type','uicontrol');
        set(h,'Enable','off');
        index=get(ROIlist(2),'Value');
        wipe(object,option.Target);
        object(index)=select(object(index),option.Target);
        updateList();
        set(h,'Enable','on');
        view(object(index),option.Target);
        figure(dlg.Handle);
    end

if ~option.Fixed
    action=addblock(dlg,'button',{'Add' 'Remove' 'Promote' 'Demote'});
    set(action(1),'Callback',@addButton);
    set(action(2),'Callback',@removeButton)
    set(action(3),'Callback',@promoteButton);
    set(action(4),'Callback',@demoteButton);
end
    function addButton(varargin)
        if numel(object) > 0
            index=get(ROIlist(2),'Value');
            mode=object(index).Mode;
        else
            mode='';
        end
        object=add(object,mode);
        updateList();
        set(ROIlist(2),'Value',numel(object));
    end
    function removeButton(varargin)
        index=get(ROIlist(2),'Value');
        object=remove(object,index);
        index=max(index-1,1);
        set(ROIlist(2),'Value',index);
        updateList();
    end
    function promoteButton(varargin)
        index=get(ROIlist(2),'Value');
        object=promote(object,index);
        index=max(index-1,1);
        set(ROIlist(2),'Value',index);
        updateList();
    end
    function demoteButton(varargin)
        index=get(ROIlist(2),'Value');
        object=demote(object,index);
        index=min(index+1,numel(object));
        set(ROIlist(2),'Value',index);
        updateList();
    end

    function updateList(varargin)
        temp=cell(numel(object),1);
        for nn=1:numel(object)
            temp{nn}=object(nn).Name;
        end
        set(ROIlist(2),'String',temp);
    end

button=addblock(dlg,'button','Done',10);
set(button(1),'Callback',@doneButton);
    function doneButton(varargin)
        wipe(object,option.Target);
        delete(dlg);
    end

locate(dlg,'center',option.Reference);
dlg.Hidden=false;

% wait for user to finish
waitfor(dlg.Handle);

end

function object=manageCurrent(object,option)

cb=SMASH.MUI2.ComponentBox();
setLabelPosition(cb,'above');

rows=10;
ROIlist=addListbox(cb,25,rows);
set(ROIlist(1),'Text','Region(s) of interest:');
updateList();
showSelection();
set(ROIlist(2),'ValueChangedFcn',@showSelection);
    function showSelection(varargin)
        wipe(object,option.Target);
        index=get(ROIlist(2),'ValueIndex');
        if index <= numel(object)
            view(object(index),option.Target);
        end
    end

width=10;
action=addButton(cb,width,5);
set(action(1),'Text','Modify','ButtonPushedFcn',@modifyAction);
set(action(2),'Text','Add','ButtonPushedFcn',@addAction);
set(action(3),'Text','Remove','ButtonPushedFcn',@removeAction);
set(action(4),'Text','Promote','ButtonPushedFcn',@promoteAction);
set(action(5),'Text','Demote','ButtonPushedFcn',@demoteAction);
if option.Fixed
    set(action(2:end),'Enable','off');
end

newRow(cb);
done=addButton(cb,width);
set(done,'Text','Done','ButtonPushedFcn',@doneButton);

fit(cb);
locate(cb,'center',option.Reference);
show(cb);

mode=object(1).Mode;

% wait for user to finish
waitfor(cb.Figure);
    function updateList(varargin)
        temp=cell(numel(object),1);
        for nn=1:numel(object)
            temp{nn}=object(nn).Name;
        end
        set(ROIlist(2),'Items',temp);
    end
    function modifyAction(varargin)
        if isempty(object)
            return
        end
        index=get(ROIlist(2),'ValueIndex');
        wipe(object,option.Target);
        object(index)=select(object(index),option.Target);
        updateList();
        view(object(index),option.Target);
        show(cb);
    end
    function addAction(varargin)
        object=add(object,mode);
        updateList();
        wipe(object,option.Target);       
        set(ROIlist(2),'ValueIndex',numel(object));        
    end
    function removeAction(varargin)
        index=get(ROIlist(2),'ValueIndex');
        object=remove(object,index);
        index=max(index-1,1);
        set(ROIlist(2),'ValueIndex',index);
        updateList();
        wipe(object,option.Target);       
    end
    function promoteAction(varargin)
        index=get(ROIlist(2),'ValueIndex');
        object=promote(object,index);
        index=max(index-1,1);
        set(ROIlist(2),'ValueIndex',index);
        updateList();
    end
    function demoteAction(varargin)
        index=get(ROIlist(2),'ValueIndex');
        object=demote(object,index);
        index=min(index+1,numel(object));
        set(ROIlist(2),'ValueIndex',index);
        updateList();
    end
    function doneButton(varargin)
        wipe(object,option.Target);
        delete(cb);
    end

end