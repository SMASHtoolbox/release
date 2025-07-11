% REPLACE Replace object grid
%
% This method replaces an object grid
%
% To replace object grid:
%     >> object=replaceGrid(object,gridName,replacementGrid);
%       -> gridName is 'Grid1' or 'Grid2'
%       -> replacementGrid is vector containing new grid values
% 
% See also Image
%

%
% created July, 2023 by Nathan Brown (Sandia National Laboratories)
%
function object=replaceGrid(object,gridName,replacementGrid)
gridName(1) = 'G';
try
    replacementGrid = reshape(replacementGrid, size(object.(gridName)));
catch
    error('Bad gridName or replacementGrid input')
end
object.(gridName) = replacementGrid;
object = verifyGrid(object);
end