% GENERATEUNITCELL - generate unit cell from lattice parameters
%
% This method generates a unit cell from the object's defined lattice
% parameters
%
% Usage:
%   >> obj = generateUnitCell(obj)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = generateUnitCell(obj)

%% volume and d calcs

obj = computeVolumeAnddCalcs(obj);

%% vectors and orientation

alpha = obj.crystal.angles(1);
beta = obj.crystal.angles(2);
gamma = obj.crystal.angles(3);
a = obj.crystal.lengths(1);
b = obj.crystal.lengths(2);
c = obj.crystal.lengths(3);
V = obj.crystal.volume;

a_vec = [a, 0, 0];
b_vec = [b*cosd(gamma), b*sind(gamma), 0];
c_vec = [c*cosd(beta), (c*(cosd(alpha) - ...
    cosd(beta)*cosd(gamma)))/ sind(gamma), V/(a*b*sind(gamma))];

obj.crystal.vectors = [a_vec; b_vec; c_vec];

% force orientation to be [0 0 0]

obj.crystal.vectorsReference = obj.crystal.vectors;
obj.crystal.orientation = [0 0 0];
obj.crystal.orientationReference = obj.crystal.orientation;
obj.crystal.lengthsReference = obj.crystal.lengths;
obj.crystal.volumeRatio = 1;


end