function object=selectLegacy(object,target)

persistent FigureTools
if isempty(FigureTools)
    FigureTools=packtools.import('SMASH.Graphics.FigureTools.*');
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

persistent ZoomPan
if isempty(ZoomPan)
    local=packtools.import('.*');
    ZoomPan=local.ZoomPan;
end
ZPstate=ZoomPan('state');
ZoomPan(fig,'on');

previous.KeyPress=get(fig,'WindowKeyPressFcn');
previous.ButtonDown=get(fig,'WindowButtonDownFcn');
previous.ButtonUp=get(fig,'WindowButtonUpFcn');
previous.Motion=get(fig,'WindowButtonMotionFcn');

% prevent ROI from causing axes to jump around
ylim(target, 'manual');
xlim(target, 'manual');

set(fig,'WindowKeypressFcn',@keypress,'WindowButtonDownFcn',@click,...
    'WindowButtonUpFcn','','WindowButtonMotionFcn','')
    function keypress(src,EventData)
        switch lower(EventData.Key)
            case {'enter' 'return'}
                figure(dlg.Handle);
            otherwise
                try
                    previous.KeyPress(src,EventData);
                catch
                end
        end
    end
ha=[];
start=[];
    function click(varargin)
        if ~strcmpi(fig.SelectionType,'normal')
            return
        end 
        ha=get(fig,'CurrentAxes');
        start=get(ha,'CurrentPoint');
        start=start(1,1:2);
        set(fig,'WindowButtonMotionFcn',@move,'WindowButtonUpFcn',@release)
    end
    function move(varargin)
        current=get(ha,'CurrentPoint');
        current=current(1,1:2);
            switch object.Mode
                case 'xy'
                    value=[start(1) current(1) start(2) current(2)];
                case 'x'
                    value=[start(1) current(1)];
                case 'y'
                    value=[start(2) current(2)];
            end
            object=define(object,value);           
            for n=1:numel(selection)
                selection(n).Data=generateTable(report(object),target);
            end
        end
    function release(varargin)
        set(fig,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
        data=report(object);
        switch object.Mode
            case {'x' 'xy'}
                set(Xbound(2),'String',sprintf('%g ',data(1:2)))
        end
        switch object.Mode
            case {'y' 'xy'}
                set(Ybound(2),'String',sprintf('%g ',data(3:4)));
        end
    end       

% create dialog
FigureTools.focus('off');

dlg=SMASH.MUI.Dialog('FontSize',get(target(1),'FontSize'));
dlg.Hidden=true;
dlg.Name='ROI settings';

Name=addblock(dlg,'edit_button',{'Name:' 'Comments'},20);
set(Name(2),'String',object.Name,'Callback',@changeName);
    function changeName(varargin)
        object.Name=get(Name(2),'String');
    end
set(Name(3),'Callback',@changeComments)
    function changeComments(varargin)
        object=comment(object);
    end

if strcmp(object.Mode,'x') ||  strcmp(object.Mode,'xy')
    Xbound=addblock(dlg,'Edit','Horizontal bounds:',20);
    value=report(object);
    value=sprintf('%g ',value(1:2));
    set(Xbound(2),'Callback',@updateXbound,...
        'String',value,'UserData',value);
end    
%
if strcmp(object.Mode,'y') ||  strcmp(object.Mode,'xy')
    Ybound=addblock(dlg,'Edit','Vertical bounds:',20);
    value=report(object);
    value=sprintf('%g ',value(3:4));
    set(Ybound(2),'Callback',@updateYbound,...
        'String',value,'UserData',value);
end
    function updateXbound(src,varargin)
        value=checkEntry(src);
        if isempty(value)
            return
        elseif strcmpi(object.Mode,'xy')
            data=report(object);
            data(1:2)=value;
            value=data;
        end
        object=define(object,value);
        for n=1:numel(selection)
            selection(n).Data=generateTable(report(object),target);
        end
    end
    function updateYbound(src,varargin)
        value=checkEntry(src);
        if isempty(value)
            return
        elseif strcmpi(object.Mode,'xy')
            data=report(object);
            data(3:4)=value;
            value=data;        
        end
        object=define(object,value);
        for n=1:numel(selection)
            selection(n).Data=generateTable(report(object),target);
        end
    end
    
Button=addblock(dlg,'button',{'Use mouse' 'Help'},10);
set(Button(1),'Callback',@useMouse);
set(dlg.Handle,'KeyPressFcn',@useMouse);
    function useMouse(varargin)
        % what if the target was deleted?
        figure(fig);
    end
set(Button(2),'Callback',@mouseHelp);
    function mouseHelp(varargin)
        FigureTools.focus('off');
        new=findall(groot,'Type','figure','Tag','RectangleSelectHelp');
        if isempty(new)
            junk=SMASH.MUI.Dialog;
            junk.Hidden=true;       
            junk.Name='Use mouse';
            HelpSummary{1}='Click/drag/release mouse to select region, press return when finished.';
            HelpSummary{end+1}='Use arrow keys to pan, shift-arrow keys to zoom.';
            HelpSummary{end+1}='Press "a" to auto scale, "t" to tight scale';
            addblock(junk,'text',HelpSummary);
            locate(junk,'center',dlg.Handle);
            trim(junk);
            junk.Hidden=false;
            new=junk.Handle;
            new.Tag='RectangleSelectHelp';
        end
        FigureTools.focus([new dlg.Handle fig]);
    end

Button(4)=addblock(dlg,'button','Done',10);
set(Button(4),'Callback',@doneButton)
    function doneButton(varargin)
        delete(selection);
        delete(dlg);
        h=findall(groot,'Type','figure','Tag','RectangleSelectHelp');        
        delete(h);   
        ylim(target, 'auto');
        xlim(target, 'auto');
    end
set(dlg.Handle,'DeleteFcn',@doneButton);


locate(dlg,'center',fig);
dlg.Hidden=false;
FigureTools.focus([dlg.Handle fig]);
waitfor(dlg.Handle);
FigureTools.focus('off');

if ishandle(fig)
    delete(selection);
    set(fig,'WindowKeyPressFcn',previous.KeyPress,...
        'WindowButtonDownFcn',previous.ButtonDown,...
        'WindowButtonUpFcn',previous.ButtonUp,...
        'WindowButtonMotionFcn',previous.Motion);
    if strcmp(ZPstate,'off')
        ZoomPan(fig,'off');
    end
end

%% helper functions    
    function value=checkEntry(box)
        temp=get(box,'String');
        [value,count,~,next]=sscanf(temp,'%g',2);
        if count ~= 2
            value=[];
            set(box,'String',get(box,'UserData'));
        else
            temp=temp(1:next-1);
            set(box,'String',temp,'UserData',temp);
        end
    end
      

end