% select Interactive curve selection
%
% This method provides interactive selection of curve points using the mouse.
%    object=select(object); % use current axes
%    object=select(object,target); % use target axes
% Simultaneous selection is performed when multiple target objects (within
% the same figure) are specified.
%
% See also Curve, define, view
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
assert(numel(object) == 1,...
    'ERROR: interactive selection must be done one region at a time');

if (nargin < 2) || isempty(target)
    target=gca;    
else
    for k=1:numel(target)
        assert(ishandle(target(k)) && strcmpi(target(k).Type,'axes'),...
            'ERROR: invalid target axes');       
    end    
end

%% display figure with existing ROI (if present)
fig=ancestor(target(1),'figure');
for k=2:numel(target)
    temp=ancestor(target(k),'figure');
    assert(temp == fig,'Target objects must be in the same figure');
end
figure(fig);

for k=1:numel(target)
    temp=view(object,target(k));
    if k == 1
       selection=repmat(temp,[numel(target) 1]);
    else
        selection(k,:)=temp;
    end        
end

if isempty(object.DefaultWidth)
    switch object.Mode
        case 'x'
            width=get(target(1),'YLim');
        case 'y'
            width=get(target(1),'XLim');
    end
    object.DefaultWidth=(width(2)-width(1))*0.05;
end

persistent ZoomPan
if isempty(ZoomPan)
    local=packtools.import('.*');
    ZoomPan=local.ZoomPan;
end
ZPstate=ZoomPan('state');
ZoomPan(fig,'on');

CurrentPoint=1;
width=max(selection(1).LineWidth,2);
scale=1.5;
for k=1:numel(target)
    temp=line('Parent',target(k),...
        'Marker','o','MarkerSize',scale*selection(1).MarkerSize,'LineWidth',width,...
        'MarkerEdgeColor',selection(1).ConjugateColor,'MarkerFaceColor',selection(1).Color,...
        'LineStyle','none','Visible','off');
    if k == 1
        highlight=repmat(temp,[numel(target) 1]);
    else
        highlight(k)=temp;
    end
end

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
                data(end+1,:)=[pos object.DefaultWidth];                
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
FigureTools.focus('off');
dlg=SMASH.MUI.Dialog('FontSize',get(target(1),'FontSize'));
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
        temp=sprintf('%g',x);
        set(Coordinate(1),'String',temp,'UserData',temp);
        y=object.Data(index,2);
        temp=sprintf('%g',y);
        set(Coordinate(2),'String',temp,'UserData',temp);
        w=object.Data(index,3);
        temp=sprintf('%g',w);
        set(Coordinate(3),'String',temp,'UserData',temp);       
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

label=get(get(target(1),'XLabel'),'String');
if isempty(label)
    label='x';
end
label=[label ' :'];
h=addblock(dlg,'edit',label,20);
Coordinate(1)=h(end);
%
label=get(get(target(1),'YLabel'),'String');
if isempty(label)
    label='y';
end
label=[label ' :'];
h=addblock(dlg,'edit',label,20);
Coordinate(2)=h(end);
%
h=addblock(dlg,'edit_button',{'Width :' 'Use everywhere'},15);
Coordinate(3)=h(2);
set(h(3),'Callback',@useWidthEverywhere);
    function useWidthEverywhere(varargin)
        w=sscanf(get(Coordinate(3),'String'),'%g');
        object.Data(:,3)=w;
        update();
        object.DefaultWidth=w;
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
            temp=[];
            temp(1)=sscanf(get(Coordinate(1),'String'),'%g',1);
            temp(2)=sscanf(get(Coordinate(2),'String'),'%g',1);
            temp(3)=sscanf(get(Coordinate(3),'String'),'%g',1);
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
set(Button(2),'Callback',@mouseHelp)
    function mouseHelp(varargin)        
        FigureTools.focus('off');
        new=findall(groot,'Type','figure','Tag','CurveSelectHelp');
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
            new.Tag='CurveSelectHelp';
        end
        FigureTools.focus([new dlg.Handle fig]);              
    end

Button(3)=addblock(dlg,'button','Done',10);
set(Button(3),'Callback',@doneButton)
    function doneButton(varargin)
        delete(dlg);
        h=findall(groot,'Type','figure','Tag','CurveSelectHelp');        
        delete(h);
        delete(selection);       
    end
set(dlg.Handle,'DeleteFcn',@doneButton);

%% show dialog
update();
locate(dlg,'center',fig);
dlg.Hidden=false;
FigureTools.focus([dlg.Handle fig]);
uiwait(dlg.Handle);
FigureTools.focus('off');

if ishandle(fig)
    delete(Selection);
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
            for n=1:size(selection,1)
                selection(n,1).Visible='off';
                selection(n,2).Visible='off';
            end
            set(highlight,'Visible','off');
            CurrentPoint=[];
            set(Coordinate,'Enable','off','String','');            
            return
        end
        %
        table=generateTable(object);
        for n=1:size(selection,1)
            selection(n,1).Data=table{1};
            selection(n,1).Visible='on';
            selection(n,2).Data=table{2};
            selection(n,2).Visible='on';
        end
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