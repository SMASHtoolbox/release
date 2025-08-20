function object=selectCurrent(object,target)

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
                %figure(dlg.Handle);
                show(cb);
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
                set(XBound(2),'Value',sprintf('%g ',data(1:2)))
        end
        switch object.Mode
            case {'y' 'xy'}
                set(YBound(2),'Value',sprintf('%g ',data(3:4)));
        end
    end       

% create dialog
FigureTools.focus('off');

cb=SMASH.MUI2.ComponentBox();
setFont(cb,[],get(target(1),'FontSize'));
setName(cb,'ROI settings');

Name=addEdit(cb,20);
Name(end+1)=addButton(cb,7);
set(Name(1),'Text','Name:');
set(Name(2),'Value',object.Name,'ValueChangedFcn',@changeName);
    function changeName(varargin)
        object.Name=get(Name(2),'Value');
    end
set(Name(3),'Text','Comennts','ButtonPushedFcn',@changeComments)
    function changeComments(varargin)
        object=comment(object);
    end
newRow(cb);

if strcmp(object.Mode,'x') ||  strcmp(object.Mode,'xy')
    XBound=addEdit(cb,20);%addblock(dlg,'Edit','Horizontal bounds:',20);
    set(XBound(1),'Text','Horizontal bounds:');
    value=report(object);
    value=sprintf('%g ',value(1:2));
    set(XBound(2),'ValueChangedFcn',@updateXbound,...
        'Value',value,'UserData',value);
end    
newRow(cb);

if strcmp(object.Mode,'y') ||  strcmp(object.Mode,'xy')
    YBound=addEdit(cb,20);%addblock(dlg,'Edit','Vertical bounds:',20);
    set(YBound(1),'Text','Vertical bounds:');
    value=report(object);
    value=sprintf('%g ',value(3:4));
    set(YBound(2),'ValueChangedFcn',@updateYbound,...
        'Value',value,'UserData',value);
end
newRow(cb);
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
    
Button(1)=addButton(cb,10);
set(Button(1),'Text','Use mouse','ButtonPushedFcn',@useMouse);
Button(2)=addButton(cb,10);
set(Button(2),'Text','Help','ButtonPushedFcn',@mouseHelp)
    function useMouse(varargin)
        % what if the target was deleted?        
        figure(fig);
    end
    function mouseHelp(varargin)
        FigureTools.focus('off');
        new=findall(groot,'Type','figure','Tag','RectangleSelectHelp');
        if isempty(new)
            junk=SMASH.MUI2.ComponentBox();
            setName(junk,'Use mouse');
            junk.Figure.Tag='RectangleSelectHelp';
            HelpSummary{1}='Click/drag/release mouse to select region, press return when finished.';
            HelpSummary{end+1}='Use arrow keys to pan, shift-arrow keys to zoom.';
            HelpSummary{end+1}='Press "a" to auto scale, "t" to tight scale.';
            HelpSummary=sprintf('%s ',HelpSummary{:});
            hs=addTextarea(junk,40,2);
            set(hs(1),'Text','Instructions:');
            set(hs(end),'Value',HelpSummary,...
                'ValueChangedFcn',@(src,~) set(src,'Value',HelpSummary));
            locate(junk(end),'center',cb.Figure);
            fit(junk);
            show(junk);
            junk.Figure.Tag='RectangleSelectHelp';
        end
        FigureTools.focus([new cb.Figure fig]);
    end
newRow(cb);

Button(3)=addButton(cb,10);
set(Button(3),'Text','Done','ButtonPushedFcn',@doneButton);
%Button(4)=addblock(dlg,'button','Done',10);
%set(Button(4),'Callback',@doneButton)
    function doneButton(varargin)
        delete(selection);
        delete(cb);
        h=findall(groot,'Type','figure','Tag','RectangleSelectHelp');        
        delete(h);   
        ylim(target, 'auto');
        xlim(target, 'auto');
    end
set(cb.Figure,'DeleteFcn',@doneButton);

fit(cb);
locate(cb,'center',fig);
show(cb);
FigureTools.focus([cb.Figure fig]);
waitfor(cb.Figure);
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