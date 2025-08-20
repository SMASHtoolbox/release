% sortTable Sort [x y] table based on distance and direction
%

%
function table=sortTable(table,start)

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
    temp=repmat(table(n,:),[n-1 1]);
    temp=table(1:(n-1),:)-temp;
    L2=temp(:,1).^2+temp(:,2).^2;
    [~,k]=min(L2);
    if k==1
        before=[table(n,:); table(1,:); table(2,:)];
        after=[table(1,:); table(n,:);  table(2,:)];
    else
        
    end
end

end