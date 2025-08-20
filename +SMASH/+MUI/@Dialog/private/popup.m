% dialog.popup : add popup block to dialog
% Usage:
%   >> h=object.popup(label,choices,minwidth);
% label is a character array ('Choices' by default)
% choices should be a cell array of strings
% minwidth defines the minimum block width in characters (optional)
function varargout=popup(object,label,choices,minwidth,SkipLabel)

% handle input
if (nargin<2) || isempty(label)
    label='Label: ';
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

if nargin<5
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

for n=1:numel(choices)
    minwidth=max(minwidth,numel(choices{n}));
end

dummy=repmat('M',[1 minwidth]);
h(end+1)=local_uicontrol(object,...
    'Style','popup','HorizontalAlignment','left',...
    'String',dummy);
set(h(end),'String',choices);
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