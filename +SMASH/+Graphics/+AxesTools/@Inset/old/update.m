% update Update inset display
%
% This method updates inset bounds and/or the inset position.  Property
% changes are no applied until this method is called.
%    object.XBound=[a b];
%    object.YBound=[c d];
%    update(object);
%
% See also AxesInset
%

%
% created January 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function update(object)

% verify objects
assert(isvalid(object),'ERROR: deleted objects cannot be updated');

assert(ishandle(object.Source),'ERROR: source axes has been deleted');

if ...
        isempty(object.Inset) || isempty(object.Rectangle) || ...
        ~ishandle(object.Inset)  || ~ishandle(object.Rectangle)
    % delete extraneous object
    if ishandle(object.Inset)
        delete(object.Inset);
    end
    if ishandle(object.Rectangle)
        delete(object.Rectangle)
    end
    % create inset
    fig=ancestor(object.Source,'figure');
    object.Inset=copyobj(object.Source,fig);
    delete(get(object.Inset,'XLabel'));
    delete(get(object.Inset,'YLabel'));
    delete(get(object.Inset,'Title'));
    ht=findall(object.Inset,'Type','text');
    delete(ht);
    set(object.Inset,'Color','none','Box','on');
    % create rectangle
    object.Rectangle=rectangle('Parent',object.Source,...
        'LineStyle','--');
    set(object.Rectangle,'ButtonDownFcn',{@AdjustRectangle,object});
    RectangleMenu(object);
end    

% position objects
SourceUnits=get(object.Source,'Units');
set(object.Source,'Units','normalized');
InsetUnits=get(object.Inset,'Units');
set(object.Inset,'Units','normalized');

SourcePosition=get(object.Source,'Position');
InsetPosition=nan(1,4);
InsetPosition(1)=SourcePosition(1)+object.Position(1)*SourcePosition(3);
InsetPosition(2)=SourcePosition(2)+object.Position(2)*SourcePosition(4);
InsetPosition(3)=object.Position(3)*SourcePosition(3);
InsetPosition(4)=+object.Position(4)*SourcePosition(4);
set(object.Inset,'Position',InsetPosition);

pos=nan(1,4);
pos(1)=object.XBound(1);
pos(2)=object.YBound(1);
pos(3)=diff(object.XBound);
pos(4)=diff(object.YBound);
set(object.Rectangle,'Position',pos);

set(object.Source,'Units',SourceUnits);
set(object.Inset,'Units',InsetUnits);

% update inset limits
xlim(object.Inset,object.XBound);
ylim(object.Inset,object.YBound);

end

function RectangleMenu(object)

hm=uicontextmenu();
uimenu(hm,'Label','Position inset',...
    'Callback',{@positionRectangle,object});
    function positionRectangle(~,~,object)
        position(object);
    end
set(object.Rectangle,'UIContextMenu',hm);

end