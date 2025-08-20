% distinct linear least squares analysis
%
% vector=matrix*param
%
function param=distinctLLS(matrix,vector,threshold)

% handle input
assert(nargin>=2,'');
[M,N]=size(matrix);
assert(M==numel(vector),'ERROR: matrix/vector sizes are inconsistent');
vector=vector(:);

if (nargin<3) || isempty(threshold)
    threshold=1e-3;
    %threshold=1e-2;
end

% identify distinct matrix columns
L=max(matrix,[],1)-min(matrix,[],1);
distinct=true(1,N);
for n=2:N
    for k=1:(n-1)
        if ~distinct(k)
            continue
        end
        change=matrix(:,n)-matrix(:,k);
        change=max(change)-min(change);       
        level=threshold*max(L(n),L(k));
        if change<level
            distinct(n)=false;
            break
        end
    end
end

% solve reduced problem and apply result
%if any(~distinct)
%    fprintf('reduce\n');
%end
Q=matrix(:,distinct);
p=Q\vector;

param=zeros(N,1);
param(distinct)=p;

end