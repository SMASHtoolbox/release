% group Define group column and width
%
% This method defines group column and width.
%    object=group(object,column,width);
%    object=group(object,column); % default width is zero
% The input "column" (integer) defines one column that is used to
% segregrate data into distinct groups.
%
% The input "width" indicates the minimum separation between groups.
% Nonzero widths place similar values into the same group, which is helpful
% for floating point values that don't match to full machine precision. For
% example, the array [1; 1.01; 2; 3] is separated into four groups by
% default and three groups for width >= 0.01.
%
% See also GroupedTable, extract
%

%
% created March 1, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=group(object,column,width)

% manage input
assert(nargin >= 2,'ERROR: insufficient number of inputs');

assert(verifyColumn(object,column),'ERROR: invalid group column');

if (nargin < 3) || isempty(width)
    width=0;
else
    assert(isnumeric(width) && isscalar(width),...
        'ERROR: invalid group width');
    width=abs(width);
end

% store group settings
object.PrivateGroupColumn=column;
object.PrivateGroupWidth=width;

end