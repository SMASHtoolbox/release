% set Change existing option value
%
% This method changes values in an existing option.
%     >> object=set(object,name,value);
% Te requested value is tested against the option's allowed values (if
% defined) before the assignment is made.
%
% Multiple options can be set at the same time.
%    >> object=set(object,name1,value1,name2,value2,...);
%
% See also Options, add, describe, get
%


%
% created November 17, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function object=set(object,varargin)

% handle input
Narg=numel(varargin);
assert(Narg>0,'ERROR: insufficient input');
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

for n=1:2:Narg
    name=varargin{n};
    value=varargin{n+1};
    index=findName(object.Name,name);
    assert(~isempty(index),'ERROR: invalid option name');
    valid=isAllowed(object.Allowed{index},value);
    assert(valid,'ERROR: invalid %s value',object.Name{index});
    object.Value{index}=value;
end

end

function flag=isAllowed(list,value)

flag=false;
if isempty(list)
    flag=true;
elseif iscell(list)
    for k=1:numel(list)
        if isnumeric(list{k}) && all(list{k}==value)
            flag=true;
            break
        elseif ischar(list{k}) && strcmp(list{k},value)
            flag=true;
            break
        end
    end
elseif isa(list,'function_handle')
    flag=feval(list,value);
end

end