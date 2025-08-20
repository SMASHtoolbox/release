% add Add to the database file
%
% This method adds a structure array to the end of *existing* database file.
%    >> add(object,record);
%
% See also SimpleDatabase, probe, write
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function add(object,record)

% verify input
assert(nargin>=2,'ERROR: insufficent number of inputs');
assert(isstruct(record),'ERROR: record(s) must be specified as a structure');

data=read(object);
name1=sort(fieldnames(data(1)));
N1=numel(name1);

name2=sort(fieldnames(record(1)));
N2=numel(name2);
assert(N1==N2,'ERROR: new records incompatible with this database');

success=true;
for n=1:N2
    if strcmp(name1{n},name2{n})
        continue
    else
        success=false;
        break
    end
end
assert(success,'ERROR: new record(s) incompatible with this database');

% merge records into data
N1=numel(data);
N2=numel(record);
data((N1+1):(N1+N2))=record;

write(object,data);

end