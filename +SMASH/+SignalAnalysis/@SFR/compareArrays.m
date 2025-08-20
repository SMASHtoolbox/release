% compareArrays Neighborhood array comparison
%
% This *static* method compares two arrays, determining if one set of
% values is greater than the other over a specified neighborhood.
%    flag=SFR.compareArrays(data,reference,nhood);
% The output "flag" is a logical array indicating where values of "data"
% are larger than the corresponding values of "reference".  The input
% "nhood" controls the number of elements used this this determination.
%
% Requesting a second output:
%    [flag,bound]=SFR.compareArrays(data,reference,nhood);
% returns a two-column array of left/right index bounds where "data" is
% larger than "reference".
% 
% See also SFR
%
function [flag,bound]=compareArrays(data,reference,nhood)

% manage input
assert(nargin == 3,'ERROR: three input arguments are required');

assert(isnumeric(data) && isnumeric(reference),...
    'ERROR: data and reference array must be numeric');
assert(ismatrix(data) && any(size(data) == 1) ...
    && ismatrix(reference) && any(size(reference) == 1),...
    'ERROR: data and reference arrays must be one dimensional');
numpoints=numel(data);
assert(numpoints == numel(reference),...
    'ERROR: data and reference arrays must have the same number of elements');

assert(testNumber(nhood) && (nhood >= 1),...
    'ERROR: neighborhood size must be >= 1');
nhood=ceil(nhood);

% compare smoothed arrays
if size(data,1) == 1
    kernel1=ones(1,nhood);
    kernel2=ones(1,2*nhood);
else
    kernel1=ones(nhood,1);
    kernel2=ones(2*nhood);
end
reference=reshape(reference,size(data));

flag=(data > reference);
flag=conv2(flag,kernel1,'same');
flag=conv2(flag == nhood,kernel2,'same');
flag=(flag > 0);

% locate boundaries on request
if nargout < 2
    return
end

change=flag(2:end)-flag(1:end-1);
count=sum(change > 0);
if flag(1)
    count=count+1;
end

temp=flag;
bound=nan(count,2);
index=1:numpoints;
for k=1:count
    start=find(temp,1,'first');
    bound(k,1)=index(start);
    temp=temp(start+1:end);
    index=index(start+1:end);
    stop=find(~temp,1,'first');
    if isempty(stop)
        stop=numel(temp);
    end
    bound(k,2)=index(stop);
    temp=temp(stop+1:end);
    index=index(stop+1:end);
end

end