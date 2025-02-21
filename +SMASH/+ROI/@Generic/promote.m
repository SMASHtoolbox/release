% promote Move region of interest up in an array
%
% This method moves a region of interest up one level in an array.
%    object=promote(object,index);
%

%
% created September 22, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=promote(object,index)

if isempty(object)
    return
end

assert(nargin == 2,'ERROR: invalid number of inputs');
assert(isscalar(index),'ERROR: promotion must be done one element at a time');

valid=1:numel(object);
assert(any(index == valid),'ERROR: invalid index')
if index > 1
    object([index-1 index])=object([index index-1]);
end

end