% clip Copy figure to the clip board
%
% This function prints a MATLAB figure to the clip board (for pasting in
% another application).
%    SMASH.Graphics.FigureTools.clip();
% By default, the current figure is copied to the clip board.  Passing a
% graphic handle clips the specified figure.
%    SMASH.Graphics.FigureTools.clip(fig);
%
% See also SMASH.Graphics.FigureTools, print
%

%
% created January 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function clip(fig)

% manage input
if nargin<1
    fig=gcf;
end
assert(ishandle(fig),'ERROR: invalid figure handle');
type=get(fig,'Type');
assert(strcmpi(type,'figure'),'ERROR: invalid figure handle');

% print figure to clip board
print(fig,'-clipboard','-dpdf');

end