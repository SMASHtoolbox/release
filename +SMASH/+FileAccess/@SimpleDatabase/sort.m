% sort Sort database records
%
% This method sorts records in an exisiting database file.  Sorting is
% performed on a specified field name.
%    >> sort(object,name);
% A third input controls the sort order.
%   >> sort(object,name,'ascend'); % default behavior
%   >> sort(object,name,'descend');
%
% See also SimpleDatabase, remove, view
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function sort(object,name,direction)

% handle input
assert(nargin>=2,'ERROR: insufficient input');

if (nargin<3) || isempty(direction)
    direction='ascend';
end
switch lower(direction)
    case {'ascend','ascending'}
        direction='ascend';
    case {'descend','descending'}
        direction='descend';
end


% verify name
data=read(object);
assert(isfield(data,name),'Invalid name');

% create sort table
N=numel(data);
table=cell(N,1);
for n=1:N
    table{n}=data(n).(name);
end

if isnumeric(data(1).(name)) || islogical(data(1).(name))
    L=cellfun(@numel,table);
    assert(all(L==L(1)),'ERROR: cannot sort nonscalar data')
    table=cell2mat(table);
end
[~,index]=sort(table,1,direction);

% sort data
data=data(index);
write(object,data);

end