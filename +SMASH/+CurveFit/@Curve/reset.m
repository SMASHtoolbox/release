% reset Reset data table and/or evaluation grid
%
% This method resets the data table and/or the evaluation grid for a Curve
% object.
%    object=reset(object,table); % change data table only
%    object=reset(object,[],grid); % change evaluation grid only
%    object=reset(object,table,grid); % change table and grid
% The input "table" can be a 2-3 column array or an object with Grid/Data
% properties.  The input "grid" can be a numeric array or 'auto'; the
% latter generates a uniformly spaced grid with 1000 points.
%
% See also Curve
%

%
% created April 17, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=reset(object,table,grid)

% manage input
assert(nargin >= 2,'ERROR: no data table specified');

if nargin < 3
    grid=[];
end

% manage data table
if isempty(table)
    assert(~isempty(object.DataTable),'EROR: invalid data table');
    table=object.DataTable;
elseif isobject(table)
    try
        assert(isprop(table,'Grid') && isprop(table,'Data'),'');
        table=[table.Grid table.Data];
    catch
        error('ERROR: unable to generate data table from input object');
    end
    if size(table,2) > 3
        table=table(:,1:3);
        warning('Object data trimmed to make three-column array');
    end
else
    assert(isnumeric(table) && ismatrix(table) ...
        && any(size(table,2) == [2 3]),...
        'ERROR: invalid data table');
end
switch(size(table,2))
    case 2
        object.Weight=[];
    case 3
        Dy=table(:,3);
        assert(all(Dy > 0),'ERROR: invalid uncertainty value(s)');
        object.Weight=1./Dy.^2;
end
object.DataTable=table;

% manage evaluation grid
if (isempty(grid) && isempty(object.EvaluationGrid)) || strcmpi(grid,'auto')
    grid=object.DataTable(:,1);
    grid=linspace(min(grid),max(grid),1000);
elseif isempty(grid)
    grid=object.EvaluationGrid;
else
    assert(isnumeric(grid),'ERROR: invalid evaluation grid');
    grid=sort(grid);
end
object.EvaluationGrid=grid(:);

end