% object=add(object,name,data); 
% object=add(object,nameA,dataA,nameB,dataB,...);

function object=add(object,varargin)

assert(nargin > 1,'ERROR: insufficient input');
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/data pair');
new=struct('Label','','Table',[]);
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name) || iscellstr(name),'ERROR: invalid group name');
    data=varargin{n+1};
    assert(ismatrix(data) && isnumeric(data) && (size(data,2) == 2),...
        'ERROR: invalid data table');
    new.Label=name;
    new.Table=data;
    if isempty(object.PrivateGroup)
        object.PrivateGroup=new;
    else
        object.PrivateGroup(end+1)=new;
    end
end

end