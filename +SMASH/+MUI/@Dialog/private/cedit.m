function varargout=cedit(object,label,minwidth,SkipLabel)

% handle input
if (nargin<2) || isempty(label)
    label='Label: ';
end

if (nargin<3) || isempty(minwidth)
    minwidth=[0 5];
elseif isscalar(minwidth)
    minwidth=repmat(minwidth,[1 2]);
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
    minwidth(1)=max(minwidth(1),numel(label));
    h=text(object,label,minwidth(1));   
end
pos1=get(h(1),'Position');
extent=get(h(1),'Extent');
pos1(4)=extent(4);
set(h(1),'Position',pos1,'HorizontalAlignment','right');

dummy=repmat('M',[1 minwidth(2)]);
h(end+1)=local_uicontrol(object,...
    'Style','edit','HorizontalAlignment','left',...
    'Max',1,'Min',0,...
    'String',dummy);
set(h(end),'String','');
pos2=get(h(2),'Position');
pos2(1)=pos1(1)+pos1(3);
set(h(2),'Position',pos2);

%center=pos2(2)+pos2(4)/2;
%pos1(2)=center-pos1(4)/2;
pos1(4)=pos2(4);
set(h(1),'Position',pos1);

object.pushup(2,1);
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