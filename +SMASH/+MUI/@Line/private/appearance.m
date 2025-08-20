%%
function appearance(~,~,target)

% create dialog box
h=findall(0,'Tag','CustomLineAppearance');
delete(h);

object=SMASH.MUI.Dialog();
set(object.Handle,'Tag','CustomLineAppearance');
object.Name='Line settings';
object.Hidden=true;

% line property settings
h=addblock(object,'text','Line properties');
set(h,'FontWeight','bold');

h=addblock(object,'edit_button',{'Color [RGB]:','select'});
color=get(target,'Color');
color=ReadColor(color);
set(h(2),'String',color);
set(h(3),'Callback',{@ChooseColor,h(2)});

h=addblock(object,'edit','Width:');
default=sprintf('%.1f',get(target,'LineWidth'));
set(h(2),'String',default);

choices={'Solid','Dashed','Dotted','Dash-dot','None'};
h=addblock(object,'popup','Style:',choices);
current=get(target,'LineStyle');
for k=1:numel(choices)
    if strcmpi(choices{k},current)
        set(h(2),'Value',k);
    end
end

% maker property settings
addblock(object,'text',' ');
h=addblock(object,'text','Marker properties');
set(h,'FontWeight','bold');

persistent MarkerStyles
if isempty(MarkerStyles)
    MarkerStyles=set(target,'Marker');
end
h=addblock(object,'popup','Marker:',MarkerStyles);
current=get(target,'Marker');
for k=1:numel(MarkerStyles)
    if strcmpi(MarkerStyles{k},current)
        set(h,'Value',k);
    end
end
 
h=addblock(object,'edit','Size:');
default=sprintf('%.1f',get(target,'MarkerSize'));
set(h(2),'String',default);

h=addblock(object,'edit_button',{'Face color:','select'});
color=get(target,'MarkerFaceColor');
color=ReadColor(color);
set(h(2),'String',color);
set(h(3),'Callback',{@ChooseColor,h(2)});


h=addblock(object,'edit_button',{'Edge color:','select'});
color=get(target,'MarkerEdgeColor');
color=ReadColor(color);
set(h(2),'String',color);
set(h(3),'Callback',{@ChooseColor,h(2)});

% buttons
h=addblock(object,'button',{'Apply','Close'});
set(h(1),'Callback',{@ApplyButton,object,target});
set(h(2),'Callback',@CloseButton);
    function CloseButton(varargin)
        delete(object);
    end

locate(object,'center');
object.Hidden=false;

end

%%
function value=ReadColor(value)

if isnumeric(value)
    value=sprintf('%.2f ',value);
end

end

%%
function ChooseColor(~,~,editbox)

color=uisetcolor;
if numel(color)==1 % user pressed cancel
    return
end
color=ReadColor(color);
set(editbox,'String',color);

end

%%
function ApplyButton(~,~,object,target)
  
value=probe(object);

% line color
color=get(target,'Color');
switch value{1}
    case {'r','g','b','c','m','y','k','w','none'}
        color=value{1};
    otherwise
        value{1}=sscanf(value{1},'%g');
        if numel(value{1})==3
            color=value{1};
        end
end
set(target,'Color',color);

% line width
width=get(target,'LineWidth');
value{2}=sscanf(value{2},'%f',1);
if ~isempty(value{2})
    width=value{2};
end
set(target,'LineWidth',width);

% line style
style=get(target,'LineStyle');
switch lower(value{3})
    case 'solid'
        style='-';
    case 'dashed'
        style='--';
    case 'dotted'
        style=':';
    case 'dash-dot'
        style='-.';
    case 'none'
        style='none';
end
set(target,'LineStyle',style);

% marker
set(target,'Marker',value{4});

% marker size
msize=get(target,'MarkerSize');
value{5}=sscanf(value{5},'%f',1);
if ~isempty(value{5})
    msize=value{5};
end
set(target,'MarkerSize',msize);

% marker face color
color=get(target,'MarkerFaceColor');
switch value{6}
    case {'r','g','b','c','m','y','k','w','none','auto'}
        color=value{6};
    otherwise
        value{6}=sscanf(value{6},'%g');
        if numel(value{6})==3
            color=value{6};
        end
end
set(target,'MarkerFaceColor',color);

% marker edge color
color=get(target,'MarkerEdgeColor');
switch value{7}
    case {'r','g','b','c','m','y','k','w','none','auto'}
        color=value{7};
    otherwise
        value{7}=sscanf(value{7},'%g');
        if numel(value{7})==3
            color=value{7};
        end
end
set(target,'MarkerEdgeColor',color);

end