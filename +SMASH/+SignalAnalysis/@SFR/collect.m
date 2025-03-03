% collect Collect reduction data
%
% This method collects reduction data from an object or object array.
%    result=collect(object); 
% By default, the most recent reduction from each element of "object" is
% combined into the output "result".  That output is a ScatteredPatch
% class object.
% 
% Specific reductions and/or elements can be collected using a second input
% argument.
%    result=collect(object,index); 
% The numeric input "index" can be a scalar or an array.
%    -Scalar values indicate the same reduction index for all object elements.
%    -A row/column array indicates reduction indices for a scalar object.
%    -A two-column array indicates [element index] values for collections.
% Zero index values always refer to the most recent reduction, and negative
% indices are references from the most recent reduction.  Positive indices
% are absolute references.  Requesting a second output:
%    [result,absolute]=collect(object,index);
% returns an array of absolute indices that corresponding to the input
% request.
%
% Constant frequency offsets can be added to each collection result.
%    result=collect(object,index,offset);
% The input "offset" can be numeric scalar or an array (one element per
% collected result).
%
% See also SFR, reduce
%
function [result,index]=collect(object,index,offset)

% manage input
M=numel(object);
if nargin < 2
    index=[];
else
    assert(isnumeric(index),'ERROR: index array must be numeric');
end
if isempty(index)
    index=zeros(M,2);
    index(:,1)=1:M;
elseif isscalar(index)
    index=repmat(index,[M 2]);
    index(:,1)=1:M;
elseif isscalar(object)
    index=repmat(index(:),[1 2]);
    index(:,1)=1;
else
    assert(ismatrix(index) && (size(index,2) == 2),...
        'ERROR: invalid index array');
end
N=size(index,1);

if (nargin < 3) || isempty(offset)
    offset=0;    
else
    assert(isnumeric(offset),'ERROR: frequency offset must be numeric');
end
if isscalar(offset)
    offset=repmat(offset,[N 1]);
else
    assert(numel(offset) == N,'ERROR: invalid number of frequency offsets');
    offset=offset(:);
end

% collect data
valid=1:M;
data=nan(0,4); % [t f dt df]
for n=1:N
    k=index(n,1);
    assert(any(k == valid),'ERROR: invalid object element');
    [new,~,index(n,2)]=...
        getResult(object(k),'reduction',index(n,2));
    temp=new.Data;
    temp(:,2)=temp(:,2)+offset(n);
    temp(:,4)=temp(:,3);
    temp(:,3)=new.RiseTime/2; 
    data=[data; temp]; %#ok<AGROW>
end

result=SMASH.SignalAnalysis.ScatterPatch(data);
result.Colormap=object.Colormap;

end