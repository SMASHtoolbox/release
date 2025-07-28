% demote Move region of interest down in an array
%
% This method moves a region of interest down one level in an array.
%    object=demote(object,index);
%

%
% created September 22, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=demote(object,index)

if isempty(object)
    return
end

assert(nargin == 2,'ERROR: invalid number of inputs');
assert(isscalar(index),'ERROR: demotion must be done one element at a time');

N=numel(object);
valid=1:N;
assert(any(index == valid),'ERROR: invalid index')
if index < N
    object([index+1 index])=object([index index+1]);
end

end