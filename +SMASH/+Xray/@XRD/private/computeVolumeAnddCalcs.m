function obj = computeVolumeAnddCalcs(obj)

%% extract values

alpha = obj.crystal.angles(1);
beta = obj.crystal.angles(2);
gamma = obj.crystal.angles(3);

a = obj.crystal.lengths(1);
b = obj.crystal.lengths(2);
c = obj.crystal.lengths(3);

%% compute values

V = a*b*c*sqrt(1 - cosd(alpha)^2 - cosd(beta)^2 - cosd(gamma)^2 ...
    + 2*cosd(alpha)*cosd(beta)*cosd(gamma));
S11 = b^2*c^2*sind(alpha)^2;
S22 = a^2*c^2*sind(beta)^2;
S33 = a^2*b^2*sind(gamma)^2;
S12 = a*b*c^2*(cosd(alpha)*cosd(beta) - cosd(gamma));
S23 = a^2*b*c*(cosd(beta)*cosd(gamma) - cosd(alpha));
S13 = a*b^2*c*(cosd(gamma)*cosd(alpha) - cosd(beta));

%% populate object

obj.crystal.volume = V;
obj.crystal.dCalcs.S11 = S11;
obj.crystal.dCalcs.S22 = S22;
obj.crystal.dCalcs.S33 = S33;
obj.crystal.dCalcs.S12 = S12;
obj.crystal.dCalcs.S23 = S23;
obj.crystal.dCalcs.S13 = S13;

end