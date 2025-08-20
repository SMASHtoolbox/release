% define Manually define curve
%
% This method manually a region of interest curve as a three-column table
% of (x,y,width) values.
%    object=define(object,table);
% Curves can also be defined by a two-column table of (x,y) with a separate
% width input.
%    object=define(object,table,width); % define (x,y) values and width
%    object=define(object,[].width); % use existing (x,y) values and define width
% The input "width" can be a scalar or array; the latter must have the same
% number elements as the number of table rows.
%
% NOTE: this method automatically sorts curve points along the independent
% direction and removes redundant values.  The output object may therefore
% have a different order and fewer oints than specified by the input table.
%
% See also Curve, report, view
%

%
% created October 3, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function [object,index]=define(object,table,width)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(isnumeric(table),'ERROR: invalid data table')
if isempty(table)
    if nargin == 2
        object.Data=[];
        return
    else
        table=object.Data;
    end
end
assert(any(size(table,2) == [2 3]),'ERROR: invalid curve table');

if nargin < 3
    width=[];
end


% process table
switch object.Mode
    case 'x'
        column=1;
    case 'y'
        column=2;
end
[~,index]=uniquetol(table(:,column));
table=table(index,:);
Nrows=size(table,1);

if size(table,2) == 2
    if isempty(width)        
        width=object.DefaultWidth;           
        assert(~isempty(width),'ERROR: no width or default width specified');
    end
    if isscalar(width)
        width=repmat(width,[Nrows 1]);
    end
    assert(numel(width) == Nrows,'ERROR: invalid width value');
    table(:,3)=width;
end
table(:,3)=abs(table(:,3));

assert(all(isfinite(table(:,3))) && all(table(:,3) > 0),...
    'ERROR: width value(s) must be finite and nonzero')

object.Data=table;

end