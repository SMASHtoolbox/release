% apply Apply PlotOptions to existing graphic(s)
%
% This method applies settings from a PlotOptions object to an existing
% graphic object.
%     >> apply(object,target); 
% The input "target" must be a graphic handle or an array of handles.
% Settings are applied to the target and all its parent objects (axes,
% figure, etc.).
%
% See also PlotOptions
%

%
% created November 17, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function apply(object,target)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');
if numel(target)>1
    for k=1:numel(target)
        apply(object,target(k));
    end
    return
end

assert(ishandle(target),'ERROR: invalid target handle');

switch get(target,'Type')
    case 'line'
        set(target,'Color',get(object,'LineColor'));
        set(target,'LineStyle',get(object,'LineStyle'));
        set(target,'LineWidth',get(object,'LineWidth'));
        set(target,'Marker',get(object,'Marker'));
        set(target,'MarkerSize',get(object,'MarkerSize'));
        set(target,'MarkerEdgeColor',get(object,'LineColor'));
        switch get(object,'MarkerStyle')
            case 'open'
                set(target,'MarkerFaceColor','none');
            case 'closed'
                set(target,'MarkerFaceColor',get(object,'LineColor'));
        end
        parent=get(target,'Parent');
        apply(object,parent);
    case 'image'
        parent=get(target,'Parent');
        apply(object,parent);
    case 'axes'
        switch get(object,'AspectRatio')
            case 'auto'
                daspect(target,'auto');
                pbaspect(target,'auto');
            case 'equal'
                daspect(target,[1 1 1]);
                pbaspect(target,[1 1 1]);
        end
        set(target,'Color',get(object,'AxesColor'));
        set(target,'Box',get(object,'Box'));
        set(target,'XDir',get(object,'XDir'));
        set(target,'YDir',get(object,'YDir'));
        parent=get(target,'Parent');
        apply(object,parent);
    case 'uipanel'
        set(target,'BackgroundColor',get(object,'PanelColor'));
        parent=get(target,'Parent');
        apply(object,parent);
    case 'figure'
        set(target,'ColorMap',get(object,'ColorMap'));
        set(target,'Color',get(object,'FigureColor'));
end


end