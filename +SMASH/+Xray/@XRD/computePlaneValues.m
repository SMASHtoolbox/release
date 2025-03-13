% COMPUTEPLANEVALUES - compute values associated with detector plane
%
% This method computes the normal, size, and orientation vectors of the
% detector plane
%
% Usage:
%   >> [planeNormal, dist, n] = computePlaneValues(obj)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function [planeNormal, dist, n] = computePlaneValues(obj)

% extract what you need from the object

planePoints = obj.detector.planePoints;
planeLoc = obj.detector.location;
shape = obj.detector.shape;

% perform calculations needed for both powder and single-crystal

planeNormal = cross(planePoints(1,:) - planeLoc, planePoints(2,:) ...
    - planeLoc);
switch shape
    case 'rectangle'
        dist1 = norm(planePoints(1,:) - planeLoc);
        dist2 = norm(planePoints(2,:) - planeLoc);
        n_height = (planePoints(1,:) - planeLoc) / dist1;
        n_width = (planePoints(2,:) - planeLoc) / dist2;
        dist = [dist1; dist2];
        n = [n_height; n_width];
    case 'circle'
        dist = norm(planePoints(1,:) - planeLoc);
        n = [];
end

end
