% create Create DataClass object from numeric data
function object=create(object,varargin)

Narg=numel(varargin);
assert(Narg==1,'ERROR: invalid number of inputs');
assert(isnumeric(varargin{1}),'ERROR: invalid input');
object.Data=varargin{1};

end