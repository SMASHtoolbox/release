% dialog.popup : add popup block to dialog
% Usage:
%   >> h=object.listbox(label,choices,minwidth);
% label is a character array ('Choices' by default)
% choices should be a cell array of strings
% minwidth defines the minimum block width in characters (optional)

function varargout=listbox(object,label,choices,minwidth,rows)

% handle input
if (nargin<2) || isempty(label)
    label='Label: ';
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

if (nargin<5) || isempty(rows)
    rows=numel(choices);
end

% error checking
verify(object);

% create block
[h,temp]=text(object,label,minwidth);
minwidth=max(temp,minwidth);
pushup(object,1,object.VerticalGap);
for n=1:numel(choices)
    minwidth=max(minwidth,numel(choices{n}));
end
dummy={repmat('M',[1 minwidth])};
dummy=repmat(dummy,[rows 1]);
h(end+1)=local_uicontrol(object,...
    'Style','listbox','HorizontalAlignment','left',...
    'String',dummy);
set(h(end),'String',choices);
pos=get(h(end),'Position');
set(h(end),'Position',pos);
pushup(object);
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