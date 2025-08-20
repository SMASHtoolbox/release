% UNDER CONSTRUCTION
%
%    setChannel(object,index,value);
%    setChannel(object,value);
function setChannel(object,index,value)

assert(isscalar(object),...
    'ERROR: channels must be set one collection at a time');

N=numel(object.Pattern);
valid=1:N;

% manage input
switch nargin
    case 0
        index=valid;
        value='';
    case 1
        index=valid;        
    case 2
        assert(isnumeric(index),'ERROR: invalid index');
        for k=1:numel(value)
            assert(any(value(k) == valid),'ERROR: invalid index')
        end
    otherwise
        error('ERROR: too many inputs');
end

% store data
for k=1:numel(index)
    object.Channel{k(index)}=value;
end

end