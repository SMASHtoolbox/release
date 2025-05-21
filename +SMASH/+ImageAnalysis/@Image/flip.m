% FLIP Flip object Data along a specified coordinate
%
% Usage:
% >> object=flip(object,coordinate);
%    "coordinate" may be 'Grid1' or 'Grid2'
%
% See also IMAGE, rotate
%

%
% created November 25, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=flip(object,coordinate)

% handle input
if (nargin<2) || isempty(coordinate)
    coordinate=questdlg('Choose flip coordinate','Flip coordinate',...
        ' Grid1 ',' Grid2 ',' cancel ',' Grid1 ');
    coordinate=strtrim(coordinate);
    if strcmp(coordinate,'cancel')
        return
    end
elseif ~strcmpi(coordinate,'Grid2') && ~strcmpi(coordinate,'Grid1')
    error('ERROR: %s is an invalid coordinate',coordinate);
end

switch lower(coordinate)
    case 'grid2'
        object.Data=object.Data(end:-1:1,:);
    case 'grid1'
        object.Data=object.Data(:,end:-1:1);
    otherwise
        error('ERROR: %s is not a valid flip coordinate');
end

object=updateHistory(object);

end