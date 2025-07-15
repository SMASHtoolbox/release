% dialog.radio : add radio block to dialog
% Usage:
%   >> h=object.radio(label,minwidth);
% label is a character array ('Label' by default)
% minwidth defines the minimum block width in characters (optional)

function varargout=radio(object,label,minwidth)

% handle input
if (nargin<2) || isempty(label)
    label='Label ';
end
if ~iscell(label)
    label={label};
end
num_label=numel(label);
if (nargin<3) || isempty(minwidth)
    minwidth=0;
end

% error checking
verify(object);

% create block
for n=1:numel(label)
    minwidth=max(minwidth,numel(label{n}));
end
dummy=repmat('M',[1 minwidth]);
h=zeros([1 num_label]);
for n=1:num_label
    h(n)=local_uicontrol(object,...
        'Style','radiobutton','HorizontalAlignment','center',...
        'String',dummy);
    set(h(n),'String',label{n});
    pos=get(h(n),'Position');
    if n==1
        object.pushup;
        object.pushup(1,object.VerticalGap);
        x0=pos(1);
    end
    pos(1)=x0;
    set(h(n),'Position',pos);
    x0=pos(1)+pos(3)+object.HorizontalGap;
    object.Controls(end+1)=h(n);
end
object.make_room;

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end