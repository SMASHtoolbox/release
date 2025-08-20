% makeGridNormal Enforce monotonically increasing grids
%
%    >> object=makeGridNormal(object);
%
% See also Image
%

%
% created June, 2023 by Nathan Brown (Sandia National Laboratories)
%
function object=makeGridNormal(object)

if ~strcmp(object.Grid1Direction, 'normal')
    object.Grid1 = object.Grid1(end:-1:1);
    object.Data = object.Data(:,end:-1:1);
end
if ~strcmp(object.Grid2Direction, 'normal')
    object.Grid2 = object.Grid2(end:-1:1);
    object.Data = object.Data(end:-1:1,:);
end

object = verifyGrid(object);

if ~strcmp(object.Grid1Direction, 'normal') || ...
        ~strcmp(object.Grid2Direction, 'normal')
    warning('Method failed to make grids normal')
end

end