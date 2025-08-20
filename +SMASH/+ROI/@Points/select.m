% select Interactive point selection
%
% This method provides interactive selection of points using the mouse.
%    object=select(object); % use current axes
%    object=select(object,target); % use target axes
%
% See also Points, define, view
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
% significantly revised October 27 by Daniel Dolan
%    -Selection begins and ends with dialog box
%    -Points can now be deleted from the dialog box
%    -Valid coordinate changes are applied immediately
%
function object=select(object,target)

persistent FigureTools
if isempty(FigureTools)
    FigureTools=packtools.import('SMASH.Graphics.FigureTools.*');
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
switch object.Mode
    case 'open'
        selection.LineWidth=0;
    otherwise
        selection.LineWidth=2;
end

persistent ZoomPan
if isempty(ZoomPan)
    local=packtools.import('.*');
    ZoomPan=local.ZoomPan;
end
ZPstate=ZoomPan('state');
ZoomPan(fig,'on');

CurrentPoint=1;
width=max(selection.LineWidth,2);
scale=1.5;
highlight=line('Parent',target,...
    'Marker','o','MarkerSize',scale*selection.MarkerSize,'LineWidth',width,...
    'MarkerEdgeColor',selection.ConjugateColor,'MarkerFaceColor',selection.Color,...
    'LineStyle','none','Visible','off');

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
                temp=get(target,'CurrentPoint');                
                temp=temp(1,1:2);
                bound=get(target,'XLim');
                if (temp(1) < bound(1)) || (temp(1) > bound(2))
                    return
                end
                bound=get(target,'YLim');
                if (temp(2) < bound(1)) || (temp(2) > bound(2))
                    return
                end                
                data=object.Data;             
                N=size(data,1);
                data(end+1,:)=temp;
                if (N > 0) && (CurrentPoint < N)
                    index=[1:CurrentPoint (CurrentPoint+2):(N+1) CurrentPoint+1];
                    data(index,:)=data;
                end
                object=define(object,data);
                if CurrentPoint < size(object.Data,1)
                    CurrentPoint=CurrentPoint+1;
                end
            case 'extend' % shift-click
                if isempty(object.Data)
                    return
                end
                pos=get(target,'CurrentPoint');
                pos=pos(1,1:2);
                L2=sum((object.Data-pos).^2,2);
                [~,index]=min(L2);
                keep=true(size(object.Data,1),1);
                keep(index)=false;
                object=define(object,object.Data(keep,:));
                if CurrentPoint > 1
                    CurrentPoint=CurrentPoint-1;
                end
            case 'alt' % control-click
                if isempty(object.Data)
                    return
                end
                pos=get(target,'CurrentPoint');
                pos=pos(1,1:2);
                L2=sum((object.Data-pos).^2,2);
                [~,index]=min(L2);
                CurrentPoint=index;
        end
        set(Selection(2),'Value',1);
        update();
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
        index=min(index,size(object.Data,1));
        CurrentPoint=index;            
        x=object.Data(index,1);
        temp=sprintf('%g',x);
        set(Coordinate(1),'String',temp,'UserData',temp);
        y=object.Data(index,2);
        temp=sprintf('%g',y);
        set(Coordinate(2),'String',temp,'UserData',temp);
        set(highlight,'XData',x,'YData',y,'Visible','on');
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

label=get(get(target,'XLabel'),'String');
if isempty(label)
    label='x';
end
label=[label ' :'];
h=addblock(dlg,'edit',label,20);
Coordinate(1)=h(end);
%
set(h,'Callback',@checkValue);
label=get(get(target,'YLabel'),'String');
if isempty(label)
    label='y';
end
label=[label ' :'];
h=addblock(dlg,'edit',label,20);
Coordinate(2)=h(end);
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
            temp(1)=sscanf(get(Coordinate(1),'String'),'%g',1);
            temp(2)=sscanf(get(Coordinate(2),'String'),'%g',1);
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
        FigureTools.focus('off');
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
        FigureTools.focus([new dlg.Handle fig]);
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
FigureTools.focus([dlg.Handle fig]);
waitfor(dlg.Handle);
FigureTools.focus('off');

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
        switch object.Mode
        case {'closed' 'convex'}
            data(end+1,:)=data(1,:);
        end        
        selection.Data=data;
        selection.Visible='on';
        %
        N=size(object.Data,1);
        label=cell(N,1);
        for n=1:N
            label{n}=sprintf('Point %d',n);
        end
        CurrentPoint=max(CurrentPoint,1);
        CurrentPoint=min(CurrentPoint,numel(label));
        set(Selection(2),'String',label,'Value',CurrentPoint,'Enable','on');
        set(Coordinate,'Enable','on');
        changePoint();
    end

end