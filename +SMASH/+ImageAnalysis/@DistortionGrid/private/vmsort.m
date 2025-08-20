% VMSORT Sort table based on vector magnitude
%
% This function sorts (x,y) data stored as columns in a table.  Data is
% sorted sequentially after the second row in the table.  Subsequent rows
% are associated with the nearest sorted row.  The new row is inserted
% before or after the nearest point based on the most consistent vector
% direction.  
%

%
% created January 6, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function [table,index]=vmsort(table,start)

% handle input
assert(nargin>0,'ERROR: no table specified');
[rows,columns]=size(table);
if columns ~= 2
    error('ERROR: table must be two-dimensional');
end

if nargin<2 
    start=[];
elseif strcmpi(start,'last')
    start=rows;
end
if isempty(start) || (start<3) 
    start=3;
end

% process table
index=transpose(1:rows);
if rows < start % trivial case
    return
end

for n=start:rows
    % find nearest sorted point
    temp=repmat(table(n,:),[n-1 1]);
    temp=table(1:(n-1),:)-temp;
    L2=temp(:,1).^2+temp(:,2).^2;
    [~,k]=min(L2);    
    % make before/after decision
    new=table(n,:);
    if k==1 % boundary insertion
        before=[new; table(1,:); table(2,:)];
        after=[table(1,:); new; table(2,:)];       
        switch DirectionTest(before,after)
            case 'before'
                local=[n 1:(n-1)]; 
            case 'after'
                local=[1 n 2:(n-1)];                
        end
    elseif k==(n-1) % boundary insertion
        before=[table(k-1,:); new; table(k,:)];
        after=[table(k-1,:); table(k,:); new];
        switch DirectionTest(before,after)            
            case 'before'
                local=[1:(k-1) n k];
            case 'after'
                local=1:n;
        end
    else % interior insertion
        before=[table(k-1,:); new; table(k,:)];
        after=[table(k,:); new; table(k+1,:)];
        switch DirectionTest(before,after)
            case 'before'
                local=[1:(k-1) n k:(n-1)]; 
            case 'after'
                local=[1:k n (k+1):(n-1)];
        end
    end
    local=local(:);
    table(1:n,:)=table(local,:);
    index(1:n)=index(local);
end

end

function result=DirectionTest(before,after)

vectorA=before(2,:)-before(1,:);
vectorA=vectorA/norm(vectorA);
vectorB=before(3,:)-before(2,:);
vectorB=vectorB/norm(vectorB);
before=dot(vectorA,vectorB);

vectorA=after(2,:)-after(1,:);
vectorA=vectorA/norm(vectorA);
vectorB=after(3,:)-after(2,:);
vectorB=vectorB/norm(vectorB);
after=dot(vectorA,vectorB);

if before>after
    result='before';
else
    result='after';
end

end