% match the position of two figures

function MatchFigures(old,new)

% probe old figure size (pixels)
units=get(old,'Units');
set(old,'Units','pixels');
pos=get(old,'Position');
set(old,'Units',units);

% set new figure size (pixels)
units=get(new,'Units');
set(new,'Position',pos,'Units',units);