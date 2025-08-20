% select Interactive point selection
%
% This method provides interactive selection of points using the mouse.
%    object=select(object); % use current axes
%    object=select(object,target); % use target axes
%
% See also Slices, define, view
%

%
% created February 28, 2017 by Justin Brown (Sandia National Laboratories)
% - modification of Points.define and Curve.define
%
function object=select(object,target)

persistent figtools
if isempty(figtools)
    figtools=packtools.import('SMASH.Graphics.FigureTools.*');
end

%% manage input
assert(isscalar(object),...
    'ERROR: interactive selection must be done one region at a time');

if (nargin < 2) || isempty(target)
    target=gca;
elseif ishandle(target)
    if strcmpi(get(target,'Type'),'figure')
        target=get(target,'CurrentAxes');        
    else
        target=ancestor(target,'axes');
    end    
else
    error('ERROR: invalid target axes');
end

%% display figure with existing ROI (if present)
fig=ancestor(target,'figure');
figure(fig);
selection=view(object,target);

persistent ZoomPan
if isempty(ZoomPan)
    local=packtools.import('.*');
    ZoomPan=local.ZoomPan;
end
ZPstate=ZoomPan('state');
ZoomPan(fig,'on');

CurrentPoint=1;
width=max(selection.LineWidth,2);
scale=2;
highlight=line('Parent',target,...
    'Marker','none','LineWidth',scale*width,'Visible','off');

previous.KeyPress=get(fig,'WindowKeyPressFcn');
previous.ButtonDown=get(fig,'WindowButtonDownFcn');
previous.ButtonUp=get(fig,'WindowButtonUpFcn');
previous.Motion=get(fig,'WindowButtonMotionFcn');

set(fig,'WindowKeypressFcn',@keypress,'WindowButtonDownFcn',@mousepress,...
    'WindowButtonUpFcn','','WindowButtonMotionFcn','')
    function keypress(src,EventData)
        switch lower(EventData.Key)
            case {'enter' 'return'}
                figure(dlg.Handle);                            
            case {'backspace' 'delete'}
                if isempty(CurrentPoint)
                    return
                end
                keep=true(size(object.Data,1),1);
                keep(CurrentPoint)=false;
                object=define(object,object.Data(keep,:));
                if CurrentPoint > 1
                    CurrentPoint=CurrentPoint-1;
                end
                update();
            otherwise
                try
                    previous.KeyPress(src,EventData);
                catch
                end
        end
    end
function mousepress(~,~)      
        switch get(fig,'SelectionType')
            case 'normal'                
                pos=getNearestTargetPoint();
                if isempty(pos)
                    return
                end
                data=object.Data;
                data(end+1,:)=pos;                
                [object,index]=define(object,data);
                [~,CurrentPoint]=max(index);                
            case 'extend'
                if isempty(object.Data)
                    return
                end
                pos=getNearestTargetPoint();
                if isempty(pos)
                    return
                end
                index=getNearestIndex(pos);
                keep=true(size(object.Data,1),1);
                keep(index)=false;
                object=define(object,object.Data(keep,:));
                if CurrentPoint > 1
                    CurrentPoint=CurrentPoint-1;
                end        
            case 'alt' % control-click
                pos=getNearestTargetPoint();
                if isempty(pos)
                    return
                end
                index=getNearestIndex(pos);                
                CurrentPoint=index;
        end
        set(Selection(2),'Value',1);
        update();
    end 
    function value=getNearestTargetPoint()
        value=[];
        for kk=1:numel(target)
            if target(kk) ~= fig.CurrentAxes
                continue
            end
            temp=get(fig.CurrentAxes,'CurrentPoint');
            temp=temp(1,1:2);
            bound=get(fig.CurrentAxes,'XLim');
            if (temp(1) < bound(1)) || (temp(1) > bound(2))
                return
            end
            bound=get(fig.CurrentAxes,'YLim');
            if (temp(2) < bound(1)) || (temp(2) > bound(2))
                return
            end
            value=temp;
            break            
        end             
    end
    function index=getNearestIndex(pos)
         xb=get(fig.CurrentAxes,'XLim');
         yb=get(fig.CurrentAxes,'YLim');
         L2=object.Data(:,1:2)-pos;
         L2(:,1)=L2(:,1)/diff(xb);
         L2(:,2)=L2(:,2)/diff(yb);
         L2=sum(L2.^2,2);
         [~,index]=min(L2);
    end
    
% create dialog
dlg=SMASH.MUI.Dialog('FontSize',get(target,'FontSize'));
dlg.Hidden=true;
dlg.Name='ROI settings';

Name=addblock(dlg,'edit_button',{'Name:' 'Comments'},20);
set(Name(2),'String',object.Name,'Callback',@changeName)
    function changeName(varargin)
        object.Name=get(Name(2),'String');
    end
set(Name(3),'Callback',@changeComments)
    function changeComments(varargin)
        object=comment(object);
    end

Selection=addblock(dlg,'popup_button',{'Current point:' ' Remove '},{'()'},20);
set(Selection(2),'Callback',@changePoint);
    function changePoint(varargin)
        index=get(Selection(2),'Value');
        CurrentPoint=index;        
        x=object.Data(index,1);
        y=object.Data(index,2);
      
        switch object.Mode
            case 'x'
                temp=sprintf('%g',x);
                set(Coordinate,'String',temp,'UserData',temp);
                xdata = [x x];
                ydata = [target.YLim(1) target.YLim(2)];
            case 'y'
                temp=sprintf('%g',y);
                set(Coordinate,'String',temp,'UserData',temp);
                ydata = [y y];
                xdata = [target.XLim(1) target.XLim(2)];
        end
        set(highlight,'XData',xdata,'YData',ydata,'Visible','on');
    end  
set(Selection(3),'Callback',@removePoint)
    function removePoint(varargin)
        index=CurrentPoint;
        keep=true(size(object.Data,1),1);
        keep(index)=false;
        object=define(object,object.Data(keep,:));       
        CurrentPoint=min(CurrentPoint,size(object.Data,1)); 
        update()
    end

switch object.Mode
    case 'x'
        label=get(get(target,'XLabel'),'String');
        if isempty(label)
            label='x';
        end
        label=[label ' :'];
        h=addblock(dlg,'edit',label,20);
        Coordinate=h(end);
        set(h,'Callback',@checkValue);
    case 'y'
        label=get(get(target,'YLabel'),'String');
        if isempty(label)
            label='y';
        end
        label=[label ' :'];
        h=addblock(dlg,'edit',label,20);
        Coordinate=h(end);
        set(h,'Callback',@checkValue);
end

%
set(Coordinate,'Callback',@checkValue);
    function checkValue(src,~)
        in=sscanf(get(src,'String'),'%s',1);
        set(src,'String',in);
        value=sscanf(in,'%g',1);
        if isempty(value)
            set(src,'String',get(src,'UserData'))            
        else
            set(src,'UserData',in);
            temp(1)=sscanf(get(Coordinate,'String'),'%g',1);
            object.Data(CurrentPoint,:)=temp;
            update();
        end
    end

Button=addblock(dlg,'button',{'Use mouse' 'Help'},10);
set(Button(1),'Callback',@useMouseButton);
set(dlg.Handle,'KeyPressFcn',@useMouseButton);
    function useMouseButton(varargin)
        % what if the target was deleted?
        figure(fig);
    end
set(Button(2),'Callback',@mouseHelp);
    function mouseHelp(varargin)
        figtools.focus('off');
        new=findall(groot,'Type','figure','Tag','PointsSelectHelp');
        if isempty(new)
            junk=SMASH.MUI.Dialog;
            junk.Hidden=true;       
            junk.Name='Use mouse';
            HelpSummary{1}='Click mouse to select points, press return when finished.';
            HelpSummary{end+1}='Delete key removes current point; shift-click removes nearest point.';
            HelpSummary{end+1}='Control-click makes the nearest point current.';
            HelpSummary{end+1}='Use arrow keys to pan, shift-arrow keys to zoom.';
            HelpSummary{end+1}='Press "a" to auto scale, "t" to tight scale';
                addblock(junk,'text',HelpSummary);            
            locate(junk,'center',dlg.Handle);
            trim(junk);
            junk.Hidden=false;
            new=junk.Handle;
            new.Tag='PointsSelectHelp';
        end
        figtools.focus([new dlg.Handle fig]);
    end

Button(3)=addblock(dlg,'button','Done',10);
set(Button(3),'Callback',@doneButton)
    function doneButton(varargin)
        delete(dlg);
        h=findall(groot,'Type','figure','Tag','PointsSelectHelp');        
        delete(h);
    end
set(dlg.Handle,'DeleteFcn',@doneButton);

%% show dialog
update();
locate(dlg,'center',fig);
dlg.Hidden=false;
figtools.focus([dlg.Handle fig]);
waitfor(dlg.Handle);
figtools.focus('off');

if ishandle(fig)
    delete(selection);
    delete(highlight);
    set(fig,'WindowKeyPressFcn',previous.KeyPress,...
        'WindowButtonDownFcn',previous.ButtonDown,...
        'WindowButtonUpFcn',previous.ButtonUp,...
        'WindowButtonMotionFcn',previous.Motion);
    if strcmp(ZPstate,'off')
        ZoomPan(fig,'off');
    end
end

%% utility functions
    function update()
        if isempty(object.Data)      
            set(Selection(2),'Enable','off','String','(none selected)');
            selection.Visible='off';
            set(highlight,'Visible','off');
            CurrentPoint=0;
            set(Coordinate,'Enable','off','String','');            
            return
        end
        %
        data=object.Data;
        x = data(:,1); y=data(:,2);
        switch object.Mode
        case 'x'
            xdata = [x(:)';x(:)';x(:)'.*inf];
            ydata = [0.*x(:)'+target.YLim(1);0.*x(:)'+target.YLim(2);x(:)'.*inf]; 
        case 'y'
            ydata = [y(:)';y(:)';y(:)'.*inf];
            xdata = [0.*y(:)'+target.XLim(1);0.*y(:)'+target.XLim(2);y(:)'.*inf]; 
        end
        xdata = xdata(:); ydata = ydata(:);
        selection.Data=[xdata ydata];
        selection.Visible='on';
        %
        N=size(object.Data,1);
        label=cell(N,1);
        for n=1:N
            label{n}=sprintf('Point %d',n);
        end
        set(Selection(2),'String',label,'Value',CurrentPoint,'Enable','on');
        set(Coordinate,'Enable','on');
        changePoint();
    end

end