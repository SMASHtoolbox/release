% select Interactive bound selection
%
% This method allows bounding lines to be selected interactively.  The
% standard call is:
%     >> object=select(object,target);
% where the optional input "target" is a handle to the axes where the
% boundary lines will be displayed and selected.  If no target is
% specified, the current axes is used.  The dialog box created with this
% call blocks program executation while the boundary lines are changed with
% with the keyboard and/or mouse. Presses the "OK" button returns a
% modified version of the original object; pressing the "Cancel" button
% returns the original object.
%
% Passing a function handle as the third input:
%     >> select(object,target,ApplyFunction);
% generates a similar dialog box without blocking program execution.  This
% mode is provided for integration with a graphical user interface.
% Pressing the "Apply" button passes the current BoundingLine object to the
% ApplyFunction.  Pressing the "Done" button does the same thing before
% closing the dialog box; pressing the "Cancel" button closes the dialog
% box.
%
% See also BoundingLines, define, view
%

%
% created November 14, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=select(object,target,ApplyFunction)

% handle input
if (nargin<2) || isempty(target)
    target=gca;
end
assert(ishandle(target),'ERROR: invalid target axes handle');

if nargin<3
    ApplyFunction=[];
else
    assert(isa(ApplyFunction,'function_handle'),'ERROR: invalid Apply function');
end

% initial setup
PreviousObject=object;
fig=ancestor(target,'figure');
hline=view(object,target);
figure(fig);

% generate dialog
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Boundary select';

addblock(dlg,'text','BoundingLines selection');
label=sprintf('Direction: %s',object.Direction);
addblock(dlg,'text',label);
addblock(dlg,'text',' ');

hlower=addblock(dlg,'edit_button',{'Lower bound:   ','select'});
hupper=addblock(dlg,'edit_button',{'Upper bound:   ','select'});
set([hlower(1) hupper(1)],'FontWeight','bold');
set([hlower(2) hupper(2)],'Callback',@updateBounds);
    function updateBounds(varargin)
        A=sscanf(get(hlower(2),'String'),'%g',1);
        if isempty(A)
            A=object.Data(1);
        end
        B=sscanf(get(hupper(2),'String'),'%g',1);
        if isempty(B)
            B=object.Data(2);
        end
        object.Data=sort([A B]);
        set(hlower(2),'String',sprintf('%+.6g',object.Data(1)));
        set(hupper(2),'String',sprintf('%+.6g',object.Data(2)));
        delete(hline);
        hline=view(object,target);
    end
updateBounds;
setappdata(hlower(3),'EditBox',hlower(2));
setappdata(hupper(3),'EditBox',hupper(2));
set([hlower(3) hupper(3)],'Callback',@useMouse);
    function useMouse(varargin)
        figure(fig);
        oldFcn=get(fig,'WindowButtonUpFcn');
        zoom(fig,'on');zoom(fig,'off'); % reset figure toggle state
        set(fig,'WindowButtonUpFcn',@WindowButtonUpFcn);
        editbox=getappdata(gcbo,'EditBox');
        function WindowButtonUpFcn(varargin)            
            temp=ancestor(gco,'axes');
            if isempty(temp) || (temp~=target)
                return
            end
            set(fig,'WindowButtonUpFcn',oldFcn);
            current=get(target,'CurrentPoint');
            current=current(1,1:2);
            switch object.Direction
                case 'horizontal'
                    current=current(2);
                case 'vertical'
                    current=current(1);
            end
            set(editbox,'String',sprintf('%.6g',current));
            updateBounds;
            figure(dlg.Handle);
        end
    end

button=addblock(dlg,'button',{'Cancel','Cancel','Cancel'});
if isempty(ApplyFunction)
    set(button(1),'String','OK','Callback','delete(gcbo);');
    set(button(2),'String','Cancel','Callback','delete(gcbf)');
    set(button(3),'Visible','off');
else
    set(button(1),'String','OK','Callback',@okCallback);
    set(button(2),'String','Apply','Callback',@applyCallback);
    set(button(3),'String','Cancel','Callback','delete(gcbf)');
end
    function okCallback(varargin)
        applyCallback;
        delete(gcbo);
    end
    function applyCallback(varargin)
        feval(ApplyFunction,object);
    end

locate(dlg,'center',fig);
dlg.Hidden=false;
set(dlg.Handle,'HandleVisibility','callback','CloseRequestFcn','');

if isempty(ApplyFunction)  
    waitfor(button(1));    
    if isvalid(dlg)
        varargout{1}=object;
    else
        varargout{1}=PreviousObject;        
    end
    delete(dlg);
    delete(hline);
end

end