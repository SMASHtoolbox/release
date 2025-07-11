% apply Apply graphic options
%
% This method applies graphic objects to a target object.
%     >> apply(object,target); 
% The input "target" must be a graphic handle or an array of handles.
%
% By default, this method applies options to the target object and all of
% its parent objects (up to the figure level).  Passing a third input:
%     >> apply(object,target,'noparent');
% applies options to the target only.
%
% See also GraphicOptions
%

%
% created December 10, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function apply(object,target,parentmode)

% handle input
assert(nargin >= 2,'ERROR: invalid number of inputs');
if numel(target)>1
    for k=1:numel(target)
        apply(object,target(k));
    end
    return
end

if (nargin<3) || isempty(parentmode) || strcmpi(parentmode,'parent')
    parentmode=true;
else
    parentmode=false;
end

assert(ishandle(target),'ERROR: invalid target handle');
parent=get(target,'Parent');

type=get(target,'type');
switch type
    case 'line'
        set(target,'Color',object.LineColor);
        set(target,'LineStyle',object.LineStyle);
        set(target,'LineWidth',object.LineWidth);
        set(target,'Marker',object.Marker);
        set(target,'MarkerSize',object.MarkerSize);
        set(target,'MarkerEdgeColor',object.LineColor);
        switch object.MarkerStyle
            case 'open'
                set(target,'MarkerFaceColor','none');
            case 'closed'
                set(target,'MarkerFaceColor',object.LineColor);
        end
    case 'image'
        parent=get(target,'Parent');
        apply(object,parent,parentmode);
        return
    case 'axes'
        switch object.AspectRatio
            case 'auto'
                daspect(target,'auto');
                pbaspect(target,'auto');
            case 'equal'
                daspect(target,[1 1 1]);
                pbaspect(target,[1 1 1]);
        end
        set(target,'Color',object.AxesColor);        
        set(target,'Box',object.Box);
        set(target,'XDir',object.XDir);
        set(target,'YDir',object.YDir);
        if ~isempty(object.Title)
            title(target,object.Title,'Interpreter','none');
        end       
    case 'uipanel'
        set(target,'BackgroundColor',object.PanelColor);
    case 'figure'
        set(target,'ColorMap',object.ColorMap);
        set(target,'Color',object.FigureColor);
end

if parentmode && ~strcmpi(type,'figure')
    apply(object,parent);
end

end