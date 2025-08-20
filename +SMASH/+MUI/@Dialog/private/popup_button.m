% dialog.popup_button : add popup/button block to dialog
% Usage:
%   >> h=object.popup_button(label,choices,minwidth);
% label is a cell array ({'Choices' 'action'} by default)
% choices should be a cell array of strings
% minwidth defines the minimum block width in characters (optional)
function varargout=popup_button(object,label,choices,minwidth)

% handle input
if (nargin<2) || isempty(label)
    label={'Label: ' 'action'};
end

if (nargin<3) || isempty(choices)
    choices={'Choice A','Choice B'};
    fprintf('Using generic popup block choices: ');
    fprintf('%s ',choices{:});
    fprintf('\n');
end

if (nargin<4) || isempty(minwidth)
    minwidth=0;
end
if isscalar(minwidth)
    minwidth=repmat(minwidth,[1 numel(label)]);
else
    assert(numel(minwidth) == numel(label),'ERROR: invalid number of widths');
end


% error checking
verify(object);

% create block
[h,temp]=text(object,label{1},minwidth(1));
minwidth(1)=max(minwidth(1),temp);
object.pushup(1,object.VerticalGap);
for n=1:numel(choices)
    minwidth(1)=max(minwidth(1),numel(choices{n}));
end
dummy=repmat('M',[1 minwidth(1)]);
h(end+1)=local_uicontrol(object,...
    'Style','popup','HorizontalAlignment','left',...
    'String',dummy);
set(h(end),'String',choices);
pushup(object,1);

%L=max(cellfun(@numel,label(2:end)));
for m=2:numel(label)
    pos=get(h(end),'Position');
    x0=pos(1)+pos(3)+object.HorizontalGap;
    ym=pos(2)+pos(4)/2;    
    L=max(numel(label{m}),minwidth(m));
    dummy=repmat('M',[1 L]);       
    h(end+1)=local_uicontrol(object,'Style','pushbutton','String',dummy,...
        'HorizontalAlignment','center'); %#ok<AGROW>
    object.Controls(end+1)=h(end);
    set(h(end),'String',label{m});
    pos=get(h(end),'Position');
    pos(1)=x0;
    pos(2)=ym-pos(4)/2;
    set(h(end),'Position',pos);
end
%pushup(object,2);
make_room(object);

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end