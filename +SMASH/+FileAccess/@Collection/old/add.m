% UNDER CONSTRUCTION
function add(object)

% error checking
assert(isscalar(object),...
    'ERROR: sources must be added one collection at a time')
assert(strcmp(object.Locked,'off'),...
    'ERROR: sources cannot be added to a locked collection')

% create new source
object.Pattern{end+1}='';
object.Channel{end+1}='';

end