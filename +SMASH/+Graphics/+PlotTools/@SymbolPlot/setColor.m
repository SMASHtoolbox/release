% setColor Set symbol/line color
%
% This method sets the symbol and line color.
%   setColor(object,value);
% The input value can be specify RGB values or a standard character value
% ('r' for red, 'g' for green, 'b' for blue, and so forth).  The default
% color is black ('k').
%
% See also SymbolPlot
%
function setColor(object,value)

% manage input
if (nargin < 2) || isempty(value)
    value='k';
elseif isnumeric(value) 
    assert((numel(value) == 3) && all(value >= 0) && all(value <= 1),...
        'ERROR: invalid RGB request');
elseif any(strcmpi(value,{'k' 'w' 'r' 'g' 'b' 'm' 'y' 'c'}))
    value=lower(value);
else
    error('ERROR: invalid color requested');
end

% apply color
set(object.Points,'Color',value);
set(object.Line,'Color',value);

object.Color=value;

end