%% local uicontrol (could be pushed out to separate classes

function varargout=local_uicontrol(object,varargin)

% create uicontrol
h=uicontrol('Parent',object.Handle,'Units','pixels');
set(h,varargin{:});

extent=get(h,'Extent');
while any(extent(3:4) == 0) % 
    pause(0.05);
    extent=get(h,'Extent');        
end
position=[object.HorizontalMargin object.VerticalMargin extent(3:4)];
set(h,'Position',position);

% style-specific tweaks
style=get(h,'Style');
switch style
    case {'pushbutton','togglebutton'}
        position(4)=1.50*position(4);
        set(h,'Position',position);
    case 'checkbox'
    case 'text'
        parent=get(h,'Parent');
        color=get(parent,'Color');
        set(h,'BackgroundColor',color);
    case 'edit'
        set(h,'BackgroundColor',[1 1 1]);
        %position(3)=1.20*position(3);
        position(4)=1.50*position(4);
        set(h,'Position',position);
    case 'popupmenu'
    case 'listbox'
        position(3)=extent(3)+extent(4);
        string=get(h,'String');
        if iscell(string)
            N=numel(string);
        else
            N=1;
        end
        position(4)=N*extent(4);
        set(h,'String','');
        extent=get(h,'Extent');
        position(4)=position(4)-N*extent(4);
        set(h,'Position',position);
    case 'slider'
        parent=get(h,'Parent');
        color=get(parent,'Color');
        set(h,'BackgroundColor',color);
end

% deal with fractional pixels
pos=getpixelposition(h);
setpixelposition(h,ceil(pos));

% handle output
if nargout>=1
    varargout{1}=h;
end

end