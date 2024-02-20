% UNDER CONSTRUCTION
%
%    setPattern(object,index,value);
%    setPattern(object,value);
function setPattern(object,index,value)

assert(isscalar(object),...
    'ERROR: patterns must be set one collection at a time');

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
        assert(ischar(value),'ERROR: pattern must be a character array');
    otherwise
        error('ERROR: too many inputs');
end

% store data
for k=1:numel(index)
    object.Pattern{k(index)}=value;
end

end