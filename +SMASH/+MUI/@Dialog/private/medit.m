function varargout=medit(object,label,minwidth,rows,fontname)

% handle input
if (nargin<2) || isempty(label)
    label='Label: ';
end

if (nargin<3) || isempty(minwidth)
    minwidth=0;
end

if (nargin<4) || isempty(rows)
    rows=1;
end

if (nargin<5) || isempty(fontname)
    fontname=get(0,'DefaultUIControlFontName');
end

% error checking
verify(object);

% create block
[h,temp]=text(object,label,minwidth);
minwidth=max(temp,minwidth);
object.pushup(1,object.VerticalGap);
dummy=repmat('M',[rows minwidth+3]);
h(end+1)=local_uicontrol(object,...
    'Style','text','HorizontalAlignment','left',...
    'Max',2,'Min',0,...
    'String',dummy,...
    'FontName',fontname);
set(h(end),'Style','edit','String','');
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