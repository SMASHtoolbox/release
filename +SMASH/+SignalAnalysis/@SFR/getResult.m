% hidden method

function [data,label,index]=getResult(object,type,index)

assert(isscalar(object),...
    'ERROR: results can only be grabbed from scalar objects');
assert(testNumber(index),'ERROR: invalid result index');

assert(ischar(type),'ERROR: invalid result type');
type=lower(type);
switch type
    case 'preview'
        data=object.Preview;
    case 'reduction'
        data=object.Reduction;
    otherwise
        error('ERROR: invalid result type');
end
N=numel(data);

if index <= 0
    index=N+index;
end
valid=1:N;
if isempty(valid)
    error('ERROR: no %ss available',type);
end
assert(any(index == valid),'ERROR: invalid %s index',type);

data=data(index);
if strcmp(object.NegativeFrequencies,'off')    
    keep=(data.Data(:,2) >= 0);
    data.Data=data.Data(keep,:);
end

label=sprintf('%d/%d',index,N);

end