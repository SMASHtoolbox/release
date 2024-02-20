% DIFFERENTIATE calculate ImageGroup derivatives
%
% This method calculates derivatives of ImageGroup Data.  Local
% polynomial smoothing (Savitzky-Golay method) is used to reduce the
% effects of noise.  The coordinate and smoothing parameters
% are specified as input arguments.
%   >> result=derivative(object,coordinate,[nhood numpoints]);
% The first input can be 'Grid1' or 'Grid2'; the second input
% defines the smoothing parameters.  For example:
%   >> dzdx=differentiate(object,'Grid1',[2 7]); 
% calculates a derivative along Grid1 with second-order smoothing over
% seven points.
%
% See also ImageGroup
%

% created February 11, 2016 by Sean Grant (Sandia National Laboratories/UT)

function object=differentiate(object,coordinate,parameters,level)

% handle input
if (nargin<2) || isempty(coordinate)
    coordinate=questdlg('Choose slice coordinate','Slice coordinate',...
        ' Grid1 ',' Grid2 ',' cancel ',' Grid1 ');
    coordinate=strtrim(coordinate);
    if strcmp(coordinate,'cancel')
        return
    end
end
if nargin<3
    parameters=[];
end
if nargin<4
    level=[];
end

% split up ImageGroup
temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    tempObj{n}=differentiate(temp{n},coordinate,parameters,level);
end

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});


end

