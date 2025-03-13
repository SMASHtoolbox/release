% view Display one or more records
%
% This method displays specific records from the database file in the
% command window.
%    >> view(object,index);
% The input "index" can specify a specific record or multipl records.
%
% See also SimpleDatabase, probe, remove, sort
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%

function view(object,index)

data=read(object);
try
    data=data(index);
catch
    error('ERROR: invalid record index');
end

for n=1:numel(data)
    fprintf('Record %d\n',index(n));
    display(data(n));
end

end