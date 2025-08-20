% DELETESIMULATION - delete simulation
%
% This method deletes the simulation
%
% Usage:
%   >> obj = deleteSimulation(obj)
%
% created December, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = deleteSimulation(obj)
obj.simulation.image = -1;
obj.simulation.current = false;
obj.simulation.hkl = nan;
obj.simulation.I = nan;
obj.simulation.xy = nan;
end