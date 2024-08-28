function remove(object,index)

assert(isscalar(object),...
    'ERROR: sources must be removed on collection at a time')
assert(strcmp(object.Locked,'off'),...
    'ERROR: sources cannot be removed from a locked collection')

% manage input
N=numel(object.Pattern);
if (nargin < 2) || isempty(index)
    index=N;
else
    assert(isnumeric(index),'ERROR: source index must be numeric')
    valid=1:N;
    for k=1:numel(index)
        assert(any(index(k) == valid),'ERROR: invalid source index')
    end
end

% remove requested source(s)
keep=true(size(object.Pattern));
keep(index)=false;
object.Pattern=object.Pattern(keep);
object.Channel=object.Channel(keep);

end