% define Manually define slices
%
% This method manually specifies a region of interest slice as a one-column
% or two-column table of either x or y values.
%    object=define(object,table);
%
% NOTE: this method automatically sorts slice points along the independent
% direction and removes redundant values.  The output object may therefore
% have a different order and fewer points than specified by the input table.
%
% See also Slices, report, view
%
%
% created February 28, 2018 by Justin Brown (Sandia National Laboratories)
% - modification of Curve.define
%
function [object,index]=define(object,table)

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
assert(any(size(table,2) == [1 2]),'ERROR: invalid slices table');


% process table
switch object.Mode
    case 'x'
        %If only specifying x values, add a 0 column of y
        if size(table,2) == 1
            table = [table table.*0];
        end 
        column=1;
    case 'y'
        %If only specifying y values, add a 0 column of x
        if size(table,2) == 1
            table = [table.*0 table];
        end 
        column=2;
end
[~,index]=uniquetol(table(:,column));
table=table(index,:);
Nrows=size(table,1);

object.Data=table;

end