% CENTER Centering ImageGroup objects
%
% This method centers an ImageGroup object based on features selected by the
% user.  Two feature types--points and ellipse--are supported. The default 
% is ellipse.  Points centering allows the user to select an arbitrary number of points, the
% centroid of which defines the Image center.  Ellipse centering also
% accepts an arbitrary number of points (though at least four points are
% required) on an ellipse that defines the center of the Image.
%
% Usage:
%   >> new=center(object); % create new object centered on selected ellipse
%   >> [object,x0,y0]=center(object); % overwrite object and return previous center
%
% see also ImageGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

function [object,x0,y0,params]=center(object,imageNumber,mode,varargin)

% handle input
if isempty(imageNumber)
    sprintf('Defaulting to Image #1 for selection')
    imageNumber=1;
end
assert(rem(imageNumber,1)==0,'Frame slection must be an integer')

if (nargin<3) || isempty(mode)
    mode='ellipse';
end

% split up ImageGroup
temp=cell(object.NumberImages,1);
[temp{:}]=split(object);

% call indicated frame
[~,x0,y0,params]=center(temp{imageNumber},mode,varargin{:});

% Perform shifts given from center function to the ImageGroup
object=shift(object,'Grid1',-x0);
object=shift(object,'Grid2',-y0);


end

