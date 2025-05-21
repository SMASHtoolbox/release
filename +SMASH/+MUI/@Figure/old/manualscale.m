% manualscale : selective manual scaling for a figure
%
% This function permits manual scaling of select axes objects within a
% figure.  When active, clicking on an axes brings up a dialog box for
% manually setting axis limits; if the figure contains a single axes, the dialog
% comes up immediately.  The figure pointer is changed to a crosshair
% while manual scaling is active.
%
% Usage:
%  >> manualcale on; % activate manual scaling on current figure
%  >> manaulscale off; % deactivate manual scaling on current figure
%  >> manaulscale(fig,state); % set manual scale state for a specified figure
%

% created May 16, 2012 by Daniel Dolan (Sandia National Laboratories)
function manualscale(varargin)

% handle input
switch nargin
    case 0
        error('ERROR: no state specified');
    case 1
        fig=gcf;
        state=varargin{1};
    case 2
        fig=varargin{1};
        state=varargin{2};
end

% determine if more than one axes is present
haxes=findobj(fig,'Type','axes');
if strcmp(state,'on') && (numel(haxes)==1)
    manual_dialog(haxes);
    return
end

switch lower(state)
    case 'on'
        WindowButton(fig,'store');
        set(fig,'Pointer','crosshair',...
            'WindowButtonDownFcn','',...
            'WindowButtonUpFcn',@callback,...
            'WindowButtonMotionFcn','');
    case 'off'
        WindowButton(fig,'recall');
    otherwise
        error('ERROR: %s is an invalid auto scale state',mode);
end    

end

function callback(varargin)

% verify click occured on an axes object
fig=gcbf;
ha=get(fig,'CurrentAxes');
hc=get(fig,'CurrentObject');
hc=ancestor(hc,'axes');
if ha~=hc
    return
end

% manual scale selected axes
selection=get(fig,'SelectionType');
switch lower(selection)
    case 'normal'
        manual_dialog(ha);    
end
zoom(fig,'reset');

end

function manual_dialog(haxes)

% create dialog
object=mui.dialog('Name','Manual Scale');
object.hide;
h.xmin=object.edit('Minimum x value:');
h.xmax=object.edit('Maximum x value:');
h.xauto=object.check('Auto scale x-axis');
h.ymin=object.edit('Minimum y value:');
h.ymax=object.edit('Maximum y value:');
h.yauto=object.check('Auto scale y-axis');
%h.button=object.button({'Apply','Done','Cancel'});
h.button=object.button({'Apply','Exit'});
movegui(object.Handle,'center');
object.show;

% fill boxes with current axis limits
ProbeAxes;
    function ProbeAxes()
        format='%.6g';
        bound=get(haxes,'XLim');
        value=sprintf(format,bound(1));
        set(h.xmin(end),'String',value,'UserData',value);        
        value=sprintf(format,bound(2));
        set(h.xmax(end),'String',value,'UserData',value);
        bound=get(haxes,'YLim');
        value=sprintf(format,bound(1));
        set(h.ymin(end),'String',value,'UserData',value);
        value=sprintf(format,bound(2));
        set(h.ymax(end),'String',value,'UserData',value);
    end

% set up callbacks
set(h.xauto,'Callback',@AutoScaleX)
    function AutoScaleX(src,varargin)
        boxes=[h.xmin(end) h.xmax(end)];
        switch get(src,'Value')
            case 0
                set(boxes,'Enable','on');
            case 1
                set(boxes,'Enable','of');
        end
    end

set(h.yauto,'Callback',@AutoScaleY)
    function AutoScaleY(src,varargin)
        boxes=[h.ymin(end) h.ymax(end)];
        switch get(src,'Value')
            case 0
                set(boxes,'Enable','on');
            case 1
                set(boxes,'Enable','of');
        end
    end

set(h.button(1),'Callback',@Apply)
    function Apply(varargin)
        SetAxes;
    end
    function SetAxes()
        if get(h.xauto,'Value')
            set(haxes,'XLimMode','auto');
        else
            bound(1)=scanbox(h.xmin(end));
            bound(2)=scanbox(h.xmax(end));
            set(haxes,'XLim',bound);
        end
        if get(h.yauto,'Value')
            set(haxes,'YLimMode','auto');
        else
            bound(1)=scanbox(h.ymin(end));
            bound(2)=scanbox(h.ymax(end));
            set(haxes,'YLim',bound);
        end
        ProbeAxes;
    end

set(h.button(2),'Callback',@Exit)
    function Exit(varargin)        
        delete(object);
    end

%set(h.button(3),'Callback',@Cancel)
%    function Cancel(varargin)
%        delete(object);
%    end

object.lock
end

function value=scanbox(hbox)

value=get(hbox,'String');
format='%g';
value=sscanf(value,format,1);
if isempty(value)
    value=get(hbox,'UserData');
    set(hbox,'String',value);
    value=sscanf(value,format,1);
end

end