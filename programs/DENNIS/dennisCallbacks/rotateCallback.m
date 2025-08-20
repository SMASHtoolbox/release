function rotateCallback(src, event)

% turn everything off

state = get(src,'State');

mainFigure = ancestor(src, 'figure', 'toplevel');
zoom(mainFigure,'off');
pan(mainFigure,'off');
datacursormode(mainFigure,'off');
rotate3d(mainFigure,'off');

mainTool = ancestor(src, 'uitoolbar');
toggleTools = findobj(mainTool, 'type', 'uitoggletool');
for ii = 1:length(toggleTools)
    set(toggleTools(ii), 'state', 'off');
end

% turn on rotation if asked for

if strcmpi(state,'on')
    set(src,'State','on');
    rotate3d(mainFigure,'on');
end

end