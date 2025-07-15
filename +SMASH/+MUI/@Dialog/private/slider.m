

function varargout=slider(object,label,minwidth,SkipLabel)

% handle input
if (nargin<2) || isempty(label)
    label='Label: ';
end

if (nargin<3) || isempty(minwidth)
    minwidth=0;
end
if isscalar(minwidth)
    minwidth(2)=5;
end

if nargin<4
     SkipLabel='';
end
if strcmpi(SkipLabel,'SkipLabel')
    SkipLabel=true;
else
    SkipLabel=false;
end

% error checking
verify(object);

% create block
if SkipLabel
    h=nan;
else
    [h,temp]=text(object,label,minwidth(1));
    minwidth(1)=max(minwidth(1),temp);
    object.pushup(1,object.VerticalGap);
end
dummy=repmat('M',[1 minwidth(1)]);
h(end+1)=local_uicontrol(object,'Style','edit','HorizontalAlignment','left',...
    'String',dummy);
object.Controls(end+1)=h(end);
set(h(end),'String','','Style','slider');
pos=get(h(end),'Position');
x0=pos(1)+pos(3)+object.HorizontalGap;
ym=pos(2)+pos(4)/2;
minwidth(2)=minwidth(2);
dummy=repmat('M',[1 minwidth(2)]);
h(end+1)=local_uicontrol(object,'Style','edit','String',dummy,...
    'HorizontalAlignment','center');
object.Controls(end+1)=h(end);
set(h(end),'String','');
pos=get(h(end),'Position');
pos(1)=x0;
pos(2)=ym-pos(4)/2;
set(h(end),'Position',pos);
pushup(object,2);
make_room(object);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end