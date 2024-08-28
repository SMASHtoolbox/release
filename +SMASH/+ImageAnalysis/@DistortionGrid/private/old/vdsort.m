% VDSORT Sort table based on vector direction
%
% This function sorts a two-dimensional table to maintain consistent
% vector directions.
%    >> table=vdsort([x(:) y(:)]);
% After sorting is complete, any vector pair created from
% three adjacent rows in the table will point in the same general
% direction, i.e. their dot product is always positive.
%

% 
% created January 3, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function table=vdsort(table,start)

% handle input
assert(nargin>0,'ERROR: no table specified');
[rows,columns]=size(table);
if columns ~= 2
    error('ERROR: table must be two-dimensional');
end

if nargin<2 
    start=[];
elseif strcmpi(start,'last')
    start=rows-1;
end
if isempty(start) || (start<3) 
    start=3;
end

% process table
if rows < start % trivial case
    return
end

for n=start:rows    
    if CheckRows(table((n-2):n,:)) 
        continue % row belongs where it is  
    end
    temp=table(n,:);
    table(2:n,:)=table(1:(n-1),:);
    table(1,:)=temp;
    if CheckRows(table(1:3,:))
        continue % row belongs at the beginning 
    end
    for k=2:(n-1)
        temp=table(k,:);
        table(k,:)=table((k-1),:);
        table(k-1,:)=temp;
        if CheckRows(table((k-1):(k+1),:))
            break % row belongs in an intermediate location
        end
    end    
end

end

function result=CheckRows(table)

vectorA=table(2,:)-table(1,:);
vectorB=table(3,:)-table(2,:);
%result=dot(vectorA,vectorB); % general case
result=vectorA(1)*vectorB(1)+vectorA(2)*vectorB(2); % two-dimensional case
result=(result>0);

end