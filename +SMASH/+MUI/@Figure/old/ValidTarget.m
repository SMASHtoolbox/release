%
function result=ValidTarget(target)


result=false;

% verify target is an axes object
type=get(target,'Type');
if ~strcmp(type,'axes')
    return
end

% ignore legend and colorbar objects
tag=get(haxes,'Tag');
if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
    return
end

result=true;