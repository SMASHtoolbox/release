% define Manually define points
%
% This method manually defines region of interest points with a two-column
% table of (x,y) values.
%    object=define(object,table);
% Values should *not* be repeated for the sake of closure; this is handled
% automatically in 'closed' and 'convex' modes.
%
% NOTE: interior points are automatically removed in 'convex' mode.  As
% such, it is possible that data stored in the object may have fewer rows
% than the specified table.
%
% See also Points, select, view
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=define(object,table)

assert(nargin == 2,'ERROR: invalid number of inputs');

errmsg='ERROR: invalid data table';
assert(isnumeric(table),errmsg)
assert((size(table,2) == 2) || isempty(table),errmsg);

object.Data=table;
table=report(object); % takes care 
object.Data=table;


end