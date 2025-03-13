function object=append(object,type,name)

% manage input
assert((nargin >=2) && ischar(type),'ERROR: invalid ROI type');

if (nargin < 3) || isempty(name)
    name='Region of interest';
end
assert(ischar(name),'ERROR: invalid name');
name=lower(name);
name(1)=upper(name(1));

% call requested constructor
persistent ns
if isempty(ns)
    ns=packtools.import('.*');
end

try
    temp=ns.(type)();
    temp.Name=name;
catch
    error('ERROR: cannot created requested ROI');
end
object(end+1)=temp;

end