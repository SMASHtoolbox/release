% mui.line : create smart line object
function varargout=line(varargin)

% create line
hline=line(varargin{:});
haxes=ancestor(hline,'axes');

% use default color if user did not specify
colorset=false;
for n=1:nargin
    value=varargin{n};
    if isnumeric(value)
        continue
    end
    if any(regexpi(value,'color'))
        colorset=true;
        break
    end    
end

if ~colorset
    num_lines=numel(findobj(haxes,'Type','line'));
    color=get(haxes,'ColorOrder');
    Ncolor=size(color,1);
    offset=rem(num_lines,Ncolor);
    if offset==0
        offset=Ncolor;
    end
    set(hline,'Color',color(offset,:));
end

% create context menu to allow user to interactively change color
cmenu=uicontextmenu();
set(hline,'UIContextMenu',cmenu);

uimenu(cmenu,'Label','Line settings','Tag','appearance',...
    'Callback',{@appearance,hline});

%uimenu(cmenu,'Label','Shift/scale','Tag','shift_scale',...
%    'Callback',[],'Enable','off');

uimenu(cmenu,'Label','Export to (x,y) file','Tag','export',...
    'Callback',[],'Enable','off');

% handle output
if nargout>=1
    varargout{1}=hline;
end

end

function appearance(~,~,hline)

mui=module('');
object=mui.dialog('Name','Line settings');
object.hide;

h=object.edit('Width:');
default=sprintf('%.1f',get(hline,'LineWidth'));
set(h(2),'String',default);

persistent LineStyles
if isempty(LineStyles)
    LineStyles=set(hline,'LineStyle');
end
choices={'Solid','Dashed','Dotted','Dash-dot','None'};
h=object.popup('Style:',choices);
current=get(hline,'LineStyle');
for k=1:numel(LineStyles)
    if strcmpi(LineStyles{k},current)
        set(h,'Value',k);
    end
end

h=object.edit_button({sprintf('%-12s','Color:'),'select'});
color=get(hline,'Color');
if isnumeric(color)
    color=sprintf('%.2f ',color);
end
set(h(2),'String',color);
set(h(3),'Callback',{@ChooseColor,h(2)});

persistent MarkerStyles
if isempty(MarkerStyles)
    MarkerStyles=set(hline,'Marker');
end
h=object.popup('Marker:',MarkerStyles);
current=get(hline,'Marker');
for k=1:numel(MarkerStyles)
    if strcmpi(MarkerStyles{k},current)
        set(h,'Value',k);
    end
end

h=object.edit('Size:');
default=sprintf('%.1f',get(hline,'MarkerSize'));
set(h(2),'String',default);

h=object.edit_button({'Face color:','select'});
color=get(hline,'MarkerFaceColor');   
color=sprintf('%.2f ',color);
if isnumeric(color)
    set(h(2),'String',color);
end
set(h(3),'Callback',{@ChooseColor,h(2)});

h=object.edit_button({'Edge color:','select'});
color=get(hline,'MarkerEdgeColor');   
if isnumeric(color)
    color=sprintf('%.2f ',color);
end
set(h(2),'String',color);
set(h(3),'Callback',{@ChooseColor,h(2)});

label={'Apply','Done','Cancel'};
h=object.button(label);
set(h,'Callback',@ButtonCallback);
    function ButtonCallback(src,varargin)
        label=strtrim(get(src,'String'));
        if strcmpi(label,'cancel')
            close(gcbf);
            return
        end
        state=object.probe;       
        set(hline,'LineWidth',sscanf(state{1},'%g',1));
        value=lower(state{2});
        switch value
            case 'solid'
                value='-';
            case 'dashed'
                value='--';
            case 'dotted'
                value=':';
            case 'dashdot'
                value='-.';
        end
        set(hline,'LineStyle',value);
        color=state{3};
        if strcmpi(color,'none')
            % do nothing
        else
            color=sscanf(color,'%g',3);
        end
        set(hline,'Color',color);
        set(hline,'Marker',state{4});
        set(hline,'MarkerSize',sscanf(state{5},'%g',1));
        color=state{6};
        if strcmpi(color,'none') || strcmpi(color,'auto')
            % do nothing
        elseif isempty(color)
            color='auto';
        else
            color=sscanf(color,'%g',3);
        end        
        set(hline,'MarkerFaceColor',color);
        color=state{7};
        if strcmpi(color,'none') || strcmpi(color,'auto');
            % do nothing
        elseif isempty(color)
            color='auto';
        else
            color=sscanf(color,'%g',3);
        end
        set(hline,'MarkerEdgeColor',color);
        if strcmpi(label,'done')
            close(gcbf);
            return
        end        
    end

object.show;
object.lock;

end

function ChooseColor(~,~,edit)

color=uisetcolor;
if numel(color)==1 % user pressed cancel
    return
end
color=sprintf('%.2f ',color);
set(edit,'String',color);
%elseif all(axes_color==color) % selection won't be visible
%    return
%else
%    set(hline,'Color',color);
%end

end