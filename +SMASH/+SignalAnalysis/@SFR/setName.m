% setName Set object names
%
% This method sets names in an object array with a base label.
%    setName(object,label)
% Each object name is constructed from the base character "label" and the
% element index.  The input "label" can also be a string/cellstr array of
% *unique* names for each object element
%
% See also SFR
%
function setName(object,label)

% manage input
assert(nargin > 1,'ERROR: insufficient input');
N=numel(object);
if ischar(label)
    name=cell(1,N);
    for n=1:N
        name{n}=sprintf('%s_%d',label,n);
    end
else
    if isstring(label)
        label=cellstr(label);
    end
    assert(numel(label) == N,...
        'ERROR: inconsistent number of object names');    
    for m=1:N
        for n=(m+1):N
            assert(~strcmp(label{m},label{m}),...
                'ERROR: object names must be unique');
        end
    end
    name=label;
end

% update names
for n=1:N
    object(n).Name=name{n};
end

end