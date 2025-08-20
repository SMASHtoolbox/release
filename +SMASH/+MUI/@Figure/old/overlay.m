% overlay : overlay data on an existing axes
%
% This function overlays (x,y) data from a file on selected axes object.
% The figure pointer is changed to a crosshair while overlay is
% active.
%
% Usage:
%  >> overlay on; % activate overlay on current figure
%  >> overlay off; % deactivate overlay on current figure
%  >> overlay(fig,state); % set overlay state for a specified figure
%
%

% created May 18, 2012 by Daniel Dolan (Sandia National Laboratories)
function overlay(varargin)

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

field={...
    'Pointer' 'PointerShapeCData' 'PointerShapeHotSpot' ...
    'WindowButtonDownFcn' 'WindowButtonUpFcn' 'WindowButtonMotionFcn'
    };
switch lower(state)
    case 'on'
        

        for n=1:numel(field)
            setappdata(fig,field{n},get(fig,field{n}));
        end
        set(fig,'Pointer','crosshair',...
            'WindowButtonDownFcn','',...
            'WindowButtonUpFcn',@callback,...
            'WindowButtonMotionFcn','');
    case 'off'
        if ~isappdata(fig,'Pointer')
            return
        end
        for n=1:numel(field)
            set(fig,field{n},getappdata(fig,field{n}));
        end              
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

% load data
[filename,pathname]=uigetfile('*.*','Select (x,y) data file');
if isnumeric(filename)
    return
else
    filename=fullfile(pathname,filename);
end

try
    temp=ColumnReader(filename,[],2);
    data.x=temp(:,1);
    data.y=temp(:,2);

catch
    errordlg('ERROR: unable to read data file','File error');
    return
end

% create overlay line (with context menu)
data.scale=[1 1];
data.shift=[0 0];
data.color='k';
data.linewidth=0.5;
[~,name,ext]=fileparts(filename);
data.name=[name ext];
hl=line('Parent',target,'UserData',data,'Tag','overlay_line');

hm=uicontextmenu('Tag','overlay');
set(hl,'UIContextMenu',hm);
uimenu(hm,'Label','Overlay file:','Enable','off');
%label=sprintf('%s overlay',name);
uimenu(hm,'Label',data.name,'Enable','off');
uimenu(hm,'Label','Scale overlay','Tag','scale',...
    'Callback',{@update_overlay,hl},'Separator','on');
uimenu(hm,'Label','Shift overlay','Tag','shift',...
    'Callback',{@update_overlay,hl});
uimenu(hm,'Label','Remove overlay','Tag','delete',...
    'Callback',{@update_overlay,hl});
uimenu(hm,'Label','Set overlay color','Tag','color',...
    'Callback',{@update_overlay,hl},'Separator','on');
uimenu(hm,'Label','Set overlay width','Tag','width',...
    'Callback',{@update_overlay,hl});
update_overlay([],[],hl);

end

function update_overlay(varargin)

hl=varargin{3};
data=get(hl,'UserData');

src=varargin{1};
if ishandle(src)
    tag=get(src,'Tag');
    switch lower(tag)
        case 'scale'
            default{1}=sprintf('%g',data.scale(1));
            default{2}=sprintf('%g',data.scale(2));
            label{1}='Horizontal scaling factor';
            label{2}='Vertical scaling factor';                        
            answer=inputdlg(label,'Scale overlay',1,default);
            if isempty(answer)
                return
            end
            [value,count]=sscanf(answer{1},'%g',1);
            if count==1
                data.scale(1)=value;                            
            end
            [value,count]=sscanf(answer{2},'%g',1);
            if count==1
                data.scale(2)=value;
            end                                            
        case 'shift'
            default{1}=sprintf('%g',data.shift(1));
            default{2}=sprintf('%g',data.shift(2));
            label{1}='Horizontal shift';
            label{2}='Vertical shift';
            answer=inputdlg(label,'Shift overlay',1,default);
            if isempty(answer)
                return
            end
            [value,count]=sscanf(answer{1},'%g',1);
            if count==1
                data.shift(1)=value;
            end
            [value,count]=sscanf(answer{2},'%g',1);
            if count==1
                data.shift(2)=value;
            end
        case 'delete'
            button=questdlg('Remove overlay?','Remove overay');
            if strcmpi(button,'yes')
                delete(hl);
            end
            return;
        case 'color'
            color=uisetcolor;
            if color==0
                return;
            else
                data.color=color;
            end
        case 'width'
            default{1}=sprintf('%g',data.linewidth);
            label{1}=sprintf('%-40s','Line width (points)');
            answer=inputdlg(label,'Line width',1,default);
            if isempty(answer)
                return
            end
            [value,count]=sscanf(answer{1},'%g',1);
            if count==1
                value=max([value 0.1]); % enforce minimum line width
                data.linewidth=max(value); 
            end
    end
end

x=data.scale(1)*data.x+data.shift(1);
y=data.scale(2)*data.y+data.shift(2);
set(hl,'XData',x,'YData',y,'UserData',data,...
    'Color',data.color,'LineWidth',data.linewidth);

end