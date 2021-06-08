% DIFFERENTIATE calculate Image derivatives
%
% This method calculates derivatives of Image Data.  Local
% polynomial smoothing (Savitzky-Golay method) is used to reduce the
% effects of noise.  The coordinate and smoothing parameters
% are specified as input arguments.
%   >> result=differentiate(object,coordinate,[nhood numpoints]);
% The first input can be 'Grid1' or 'Grid2'; the second input
% defines the smoothing parameters.  For example:
%   >> dzdx=differentiate(object,'Grid1',[2 7]); 
% calculates a derivative along Grid1 with second-order smoothing over
% seven points.
%
% See also Image
%

%
% created November 24, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=differentiate(object,coordinate,parameters,level)

% verify uniform grid
object=makeGridUniform(object);

% handle input
if (nargin<2) || isempty(coordinate)
    coordinate=questdlg('Choose slice coordinate','Slice coordinate',...
        ' Grid1 ',' Grid2 ',' cancel ',' Grid1 ');
    coordinate=strtrim(coordinate);
    if strcmp(coordinate,'cancel')
        return
    end
elseif ~strcmpi(coordinate,'Grid1') && ~strcmpi(coordinate,'Grid2')
    error('ERROR: %s is an invalid coordinate',coordinate);
end

if (nargin<3) || isempty(parameters)
    parameters=[1 3];
end

if (nargin<4) || isempty(level)
    level=1; % first derivative
end

% calculate derivative
kernel=SGderivative(level,parameters);
switch lower(coordinate)
    case 'grid2'
        kernel=reshape(kernel,[],1);        
        q=object.Grid2;
    case 'grid1'
        kernel=reshape(kernel,1,[]);
        q=object.Grid1;
end
object.Data=conv2(object.Data,kernel,'same');

if level>0
    dq=(max(q)-min(q))/(numel(q)-1);
    object.Data=object.Data/(dq^level);
end

end

