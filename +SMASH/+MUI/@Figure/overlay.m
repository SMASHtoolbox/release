function overlay(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','overlay','ToolTipString','Overlay (x,y) data',...
            'Cdata',local_graphic('OverlayIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.Overlay=h;
    case 'hide'
        set(object.Button.Overlay,'Visible','off');
    case 'show'
        set(object.Button.Overlay,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        %fig=object.Handle;
        if strcmpi(state,'on')            
            set(src,'State','on');
            set(object.Handle,'Pointer','crosshair',...
                'WindowButtonUpFcn',@ButtonUp);
        end
    end

end

function ButtonUp(varargin)

% initial preparation
fig=gcbf;
selection=get(fig,'SelectionType');
if ~strcmpi(selection,'normal')
    return
end

target=get(fig,'CurrentAxes');
tag=get(target,'Tag');
if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
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
    temp=mui.tools.ColumnReader(filename,[],2);
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
%hl=line('Parent',target,'UserData',data,'Tag','overlay_line');
hl=mui.CustomLine('Parent',target,'UserData',data,'Tag','overlay_line');

%hm=uicontextmenu('Tag','overlay');
%set(hl,'UIContextMenu',hm);
hm=get(hl,'UIContextMenu');
uimenu(hm,'Label','Overlay file:','Enable','off');
%label=sprintf('%s overlay',name);
uimenu(hm,'Label',data.name,'Enable','off');
uimenu(hm,'Label','Scale overlay','Tag','scale',...
    'Callback',{@update_overlay,hl},'Separator','on');
uimenu(hm,'Label','Shift overlay','Tag','shift',...
    'Callback',{@update_overlay,hl});
uimenu(hm,'Label','Remove overlay','Tag','delete',...
    'Callback',{@update_overlay,hl});
update_overlay([],[],hl);

hc=get(hm,'Children');
hc=[hc(end-1); hc(end); hc(1:end-2)];
set(hm,'Children',hc);
set(hc(2),'Separator','on');

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
end