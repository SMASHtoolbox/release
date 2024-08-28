% pop Pop value off of data stack
%
% This method pops values off a named data stack.
%    value=DataStack.pop(name);
% The input "name" must match the name of an existing stack, i.e. one that
% has been pushed to during the current MATLAB session. 
%
% Empty stacks, where the pop method has been called more times than the
% push method, return empty values.
%
% See also DataStack, push, probe
%

%
% created November 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function value=pop(name)

assert(nargin >= 1,'ERROR: no stack name specified');
assert(isvarname(name),'ERROR: invalid stack name');

% access stack
try    
    value=manageStack('pop',name);
catch ME
    throwAsCaller(ME);
end


end