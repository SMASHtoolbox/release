% push Push value onto data stack
%
% This method pushes a value onto a named data stack.
%    DataStack.push(name,value);
% The input "name" must be a valid MATLAB variable name.  The input "value"
% is pushed onto that stack.
% 
% See also pop, probe, isvarname
%

%
% created November 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function push(name,value)

% manage input
assert(nargin == 2,'ERROR: invalid number of inputs');
assert(isvarname(name),'ERROR: invalid stack name');

% access stack
manageStack('push',name,value);

end