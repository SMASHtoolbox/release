% UNDER CONSTRUCTION
function removePatches(range,target)

% manage input
assert(nargin > 0,'ERROR: quality range must be specified');
assert(isnumeric(range) && (numel(range) == 2),...
    'ERROR: invalid quality range')
range=sort(range);
assert(diff(range) > 0,'ERROR: quality range width must be > 0');

if (nargin < 2) || isempty(target)
    target=findobj(groot,'Type','figure');
else
    assert(ishandle(target),'ERROR: invalid target handle');
    for k=1:numel(target)
        type=get(target(k),'Type');
        if strcmpi(type,'figure') || strcmpi(type,'axes')
            continue
        else
            target(k)=ancestor(target(k),'figure');
        end
    end
end

% find SFR patches
for k=1:numel(target)
    h=findobj(target(k),'Type','patch','Tag','SFR');
    for m=1:numel(h)
        C=get(h(m),'CData');
        if any(C < range(1)) || any(C > range(2))
            delete(h(m));
        end
    end
end

end