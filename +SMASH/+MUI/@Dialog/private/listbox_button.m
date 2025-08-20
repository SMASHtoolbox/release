% dialog.listbox_button : add listbox with button(s) block to dialog
% Usage:
%   >> h=object.listbox_button(label,choices,minwidth);
% label is a character array ('Choices' by default)
% choices should be a cell array of strings
% minwidth defines the minimum block width in characters (optional)

function varargout=listbox_button(object,label,choices,minwidth,rows)

% handle input
if (nargin<2) || isempty(label)
    label={'Label: ',' button '};
end

if (nargin<3) || isempty(choices)
    choices={'Item A','Item B'};
    fprintf('Using generic list block items: ');
    fprintf('%s ',choices{:});
    fprintf('\n');
end

if (nargin<4) || isempty(minwidth)
    minwidth=0;
end
if isscalar(minwidth)
    minwidth(2)=0;
end


if (nargin<5) || isempty(rows)
    rows=numel(choices);
end

% error checking
verify(object);

% create block
[h,temp]=text(object,label{1},minwidth(1));
minwidth(1)=max(temp,minwidth(1));
pushup(object,1,object.VerticalGap);

for n=1:numel(choices)
    minwidth(1)=max(minwidth(1),numel(choices{n}));
end
dummy={repmat('M',[1 minwidth(1)])};
dummy=repmat(dummy,[rows 1]);
h(end+1)=local_uicontrol(object,...
    'Style','listbox','HorizontalAlignment','left',...
    'String',dummy);
set(h(end),'String',choices);
pos=get(h(end),'Position');
set(h(end),'Position',pos);

for n=2:numel(label)
    minwidth(2)=max(minwidth(2),numel(label{n}));    
end
for n=2:numel(label)
    pos=get(h(end),'Position');
    x0=pos(1)+pos(3)+object.HorizontalGap;
    ym=pos(2)+pos(4)/2;
    dummy=repmat('M',[1 minwidth(2)]);
    h(end+1)=local_uicontrol(object,'Style','pushbutton','String',dummy,...
        'HorizontalAlignment','center');
    object.Controls(end+1)=h(end);
    set(h(end),'String',label{2});
    pos=get(h(end),'Position');
    pos(1)=x0;
    pos(2)=ym-pos(4)/2;
    set(h(end),'Position',pos);
end

align(h(2:end),'None','Top');
pushup(object,numel(label));
make_room(object);

object.Controls(end+1)=h(end);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end