% dialog.edit_check : add edit/check block to dialog
% Usage:
%   >> h=object.edit_check(label,minwidth)
% 'label' is a cell array of strings (label + check box)
% minwidth defines the minimum block width in characters (optional)

function varargout=edit_check(object,label,minwidth,SkipLabel)

% handle input
if (nargin<2) || isempty(label)
    label={'Label: ','State'};
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
    h=[];
else
    [h,temp]=text(object,label{1},minwidth);
    minwidth=max(minwidth,temp);
    pushup(object,1,object.VerticalGap);
end
dummy=repmat('M',[1 minwidth]);
h(end+1)=local_uicontrol(object,'Style','edit','HorizontalAlignment','left',...
    'String',dummy);
object.Controls(end+1)=h(end);
set(h(end),'String','');
pos=get(h(end),'Position');
x0=pos(1)+pos(3)+object.HorizontalGap;
ym=pos(2)+pos(4)/2;
dummy=repmat('M',[1 numel(label{2})]);

h(end+1)=local_uicontrol(object,'Style','checkbox','String',dummy,...
    'HorizontalAlignment','left');
object.Controls(end+1)=h(end);
set(h(end),'String',label{2});
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