function object=changeStatus(object,new,varargin)

% manage input
if (nargin < 2) || isempty(new)
    new='incomplete';
else
    assert(ischar(new),'ERROR: invalid status value');
end
new=lower(new);

if nargin < 3
    varargin=fieldnames(object.Status);
end

for n=1:numel(varargin)
    varargin{n}(1)=upper(varargin{n}(1));
    switch new        
        case 'incomplete'
            object.Status.(varargin{n})='incomplete';
        case 'complete'
            object.Status.(varargin{n})='complete';
        case 'obsolete'
            if strcmpi(object.Status.(varargin{n}),'complete')
                object.Status.(varargin{n})='obsolete';
            end
    end        
end