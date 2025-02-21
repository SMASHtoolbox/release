% Extract Extract grouped data
%
% This method extracts grouped data from a table.
%    result=extract(object);
% The output is a structure array of grouped data using all table columns
% (including the group column).  Fields in this structure include:
%    -'Data' for the extracted data of one group
%    -'Group' for the average value of one group
%    -'GroupList' for a list of all vales that fall within one group
%
% Passing a second input:
%    result=extract(object,select);
%    result=extract(object,'all'); % select all columns
% extracts grouped data for the column numbers specified in "select".
% Columns are selected by integer index and can be specified in any order.
%
% See also GroupedTable, group
%

%
% created March 1, 2018 by Daniel Dolan (Sandia National Laboratories)
% 
function result=extract(object,column)

% manage input
valid=1:object.Columns;
if (nargin < 2) || isempty(column) || strcmpi(column,'all')
    column=valid;
else
    assert(verifyColumn(object,column),'ERROR: invalid column request');    
    column=reshape(column,[1 numel(column)]);
end

% extract data
data=object.Data(:,column);
z=object.Data(:,object.GroupColumn);
[group,~,index]=uniquetol(z,object.GroupWidth,'DataScale',1);
result=struct('Data',[],'Group',[],'GroupList',[]);
result=repmat(result,size(group));
for n=1:numel(group)
    keep=(index == n);    
    result(n).Data=data(keep,:);   
    result(n).Group=mean(z(keep));
    result(n).GroupList=z(keep);    
end

end