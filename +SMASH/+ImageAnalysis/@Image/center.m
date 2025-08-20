% CENTER Centering Image objects
%
% This method centers a Image object based on features selected by the
% user.  Two feature types--points and ellipse--are supported.  Points
% centering allows the user to select an arbitrary number of points, the
% centroid of which defines the Image center.  Ellipse centering also
% accepts an arbitrary number of points (though at least four points are
% required) on an ellipse that defines the center of the Image.
%
% Usage:
%   >> new=center(object); % create new object centered on selected ellipse
%   >> [object,x0,y0]=center(object); % overwrite object and return previous center
%
% See also IMAGE

% created April 8, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 17, 2013 by Tommy Ao (Sandia National Laboratories)
%
function [object,x0,y0,params]=center(object,mode,varargin)

% handle input
if (nargin<2) || isempty(mode)
    mode='ellipse';
end

% call appropriate method
switch lower(mode)
    case 'ellipse'
        [object,params]=center_ellipse(object,varargin{:});        
        x0=params(1);
        y0=params(2);
    case 'points'
        [object,x0,y0]=center_points(object);
    otherwise
        error('ERROR: %s is an unsupported center mode');
end

object=updateHistory(object);

end