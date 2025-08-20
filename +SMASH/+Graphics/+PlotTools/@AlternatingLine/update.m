function update(object)

assert(isvalid(object),'ERROR: object cannot be updated');
if isempty(object.Group)
    return
end

% verify (x,y) data
x=object.XData(:);
y=object.YData(:);
if numel(x)==numel(y)
    % do nothing
elseif numel(x)==1
    x=repmat(x,[numel(y) 1]);
elseif numel(y)==1
    y=repmat(y,[numel(x) 1]);
else
    set(object.Group,'Visible','off');
    return
end

if numel(x)>0
    set(object.Group,'Visible','on');
else
    set(object.Group,'Visible','off');
end

% apply data
h=get(object.Group,'Children');
h=h(end:-1:1); 

set(h,'XData',x);
set(h,'YData',y);

set(h(1),'Color',object.BackgroundColor,'LineStyle','-');
set(h(2),'Color',object.ForegroundColor,...
    'LineStyle',object.ForegroundStyle);

set(h,'LineWidth',object.LineWidth);

set(h,'Visible',object.Visible);

end