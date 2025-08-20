% add Add option to an Options object
%
% This method adds a new option to an existing Options object.
%    >> object=add(object,name,default,allowed);
% The inputs "name" and "default" are required.  A unique name must be
% specified--an error is thrown if the requested name is already in use.
% The default value must be a numeric or character array.
% 
% The final input, "allowed", is optional.  If omitted, any value can be
% assigned to an option after it has been added.  Option assignments can be
% restricted by specifing a cell array of allowed values or a function
% handle that determines if value is allowed.  For example, either of the
% following commnds restrict an option named "mode" to numeric values 1, 2,
% 3.
%     >> object=add(object,'mode',1,{1 2 3}); % method A
%     >> object=add(object,'mode',@testMode); % method B
% To use method B, the function handle must accept a single input and
% return a logical output as shown below.
%     function result=testMode(value)
%     switch value
%        case {1 2 3}
%           test=true;
%        otherwise
%           test=false;
%     end
% Method A is typically easier for options having  a small number
% of allowed values.  Method B is more appropriate for options that can
% take on a continuous range of values.
%
% See also Options, remove
%

%
% created November 16, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=add(object,name,default,allowed)

% handle input
assert(nargin>=3,'ERROR: insufficient input');

assert(isvarname(name),'ERROR: invalid "name" input');

%assert(isnumeric(default) | ischar(default),'ERROR: invalid default value');
if nargin<4
    allowed=[];
end

assert(isempty(allowed) | iscell(allowed) | isa(allowed,'function_handle'),...
    'ERROR: invalid "allowed" input');

% add name unless already present
index=findName(object.Name,name);
assert(isempty(index),'ERROR: name already in use');

object.Name{end+1}=name;
object.Value{end+1}=default;
object.Allowed{end+1}=allowed;
object.Description{end+1}='[no description provided]';
object.DescriptionLock{end+1}=false;

end