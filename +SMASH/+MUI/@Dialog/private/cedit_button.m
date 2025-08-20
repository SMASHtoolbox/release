% Usage:
%   >> h=object.cedit_check(label,minwidth)
% label is a cell array of strings (label + button)
% minwidth defines the minimum button width in characters (optional).

function varargout=cedit_button(object,label,minwidth,SkipLabel)

% handle input
if (nargin<2) || isempty(label)
    label={'Label: ',' button '};
end

if (nargin<3) || isempty(minwidth)
    minwidth=[0 5 0];
end
if isscalar(minwidth)
    minwidth=repmat(minwidth,[1 3]);
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
    [h,temp]=text(object,label{1},minwidth(1));
    minwidth(1)=max(minwidth(1),temp);
end
pos1=get(h(1),'Position');
extent=get(h(1),'Extent');
pos1(4)=extent(4);
set(h(1),'Position',pos1,'HorizontalAlignment','right');

dummy=repmat('M',[1 minwidth(2)]);
h(2)=local_uicontrol(object,'Style','edit','HorizontalAlignment','left',...
    'String',dummy);
object.Controls(end+1)=h(end);
set(h(2),'String','');
pos2=get(h(2),'Position');
pos2(1)=pos1(1)+pos1(3);
set(h(2),'Position',pos2);

pos1(4)=pos2(4);
set(h(1),'Position',pos1);

for n=2:numel(label)
    minwidth(3)=max(numel(label{n}),minwidth(3));
end

for n=2:numel(label)
    pos=get(h(end),'Position');
    x0=pos(1)+pos(3)+object.HorizontalGap;
    ym=pos(2)+pos(4)/2;
    dummy=repmat('M',[1 minwidth(3)]);
    h(end+1)=local_uicontrol(object,'Style','pushbutton','String',dummy,...
        'HorizontalAlignment','center'); %#ok<AGROW>
    object.Controls(end+1)=h(end);
    set(h(end),'String',label{n});
    pos=get(h(end),'Position');
    pos(1)=x0;
    pos(2)=ym-pos(4)/2;
    set(h(end),'Position',pos);
end

object.pushup(numel(label),1);
make_room(object);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end