function varargout=edit(object,label,minwidth,SkipLabel)

% handle input
if (nargin<2) || isempty(label)
    label='Label: ';
end

if (nargin<3) || isempty(minwidth)
    minwidth=0;
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
    [h,temp]=text(object,label,minwidth);
    minwidth=max(temp,minwidth);
    object.pushup(1,object.VerticalGap);
end

dummy=repmat('M',[1 minwidth]);
h(end+1)=local_uicontrol(object,...
    'Style','edit','HorizontalAlignment','left',...
    'Max',1,'Min',0,...
    'String',dummy);
set(h(end),'String','');
object.pushup;
object.make_room;

object.Controls(end+1)=h(end);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end