% spawn Create new figure in a specific place
%
% This method creates a new figure in a specific place.  New figures can be
% spawned on a particular monitor
%    spawn(monitor);
% specified by number, 'largest', or 'smallest'; the default choice is
% 'largest'.  Figure location on that monitor can also be controlled.
%    spawn(monitor,location);
% Valid locations include 'east', 'west', 'north', 'south', 'northeast',
% 'southweast', 'northwest', 'southwest', and 'center' (default).
%
% The figure handle is returned as an output, if requested.
%    h=spawn(...); 
%
% <a href="matlab:SMASH.System.showExample('Spawn','+SMASH/+Graphics/+FigureTools')">Examples</a>
%
% See also SMASH.Graphics.FigureTools, place
%

%
% created December 14, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=spawn(monitor,location)

import SMASH.Graphics.FigureTools.*

% manage input
if (nargin < 1)
    monitor=[];
end

if (nargin < 2) || isempty(location)
    location='center';
end


% generate new figure
fig=figure();
try
    place(monitor,fig);
catch
    delete(fig);
    error('ERROR: invalid monitor');
end

try
    movegui(fig,location);
catch
    delete(fig);
    error('ERROR: invalid location');
end

% manage output
if nargout > 0
    varargout{1}=fig;
end
   
end