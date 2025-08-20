% dialog.button : add button block to dialog
% Usage:
%   >> h=object.button(label,minwidth);
% label is a character array (single button) or a cell array of strings (multiple buttons)
% minwidth defines the minimum button width in characters (optional)

function varargout=button(object,label,minwidth)

% handle input
if (nargin<2) || isempty(label)
    label=' Button ';
end
if ~iscell(label)
    label={label};
end
if (nargin<3) || isempty(minwidth)
    minwidth=0;
end
num_label=numel(label);

% error checking
verify(object);

% create buttons
for n=1:numel(label)
    minwidth=max(minwidth,numel(label{n}));
end
dummy=repmat('M',[1 minwidth]);
h=zeros([1 num_label]);
for n=1:num_label
    h(n)=local_uicontrol(object,...
        'Style','pushbutton','HorizontalAlignment','center',...
        'String',dummy);
    set(h(n),'String',label{n});
    pos=get(h(n),'Position');
    if n==1
        pushup(object);
        pushup(object,1,object.VerticalGap);
        x0=pos(1);
    end
    pos(1)=x0;
    set(h(n),'Position',pos);
    x0=pos(1)+pos(3)+object.HorizontalGap;
    object.Controls(end+1)=h(n);
end
make_room(object);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end