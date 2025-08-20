% SETSIMULATIONDEFAULTS - restore default simulation settings
%
% This method restores default simulation settings
%
% Usage:
%   >> obj = setSimulationDefaults(obj)
%
% created December, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = setSimulationDefaults(obj)

obj.simulation = struct; % delete any old stuff
obj.simulation.mosaicity = 180*ones(1,3);
obj.simulation.max_hkl = 6;
obj.simulation.simulationSize = 1e3;
obj.simulation.pixelNum = 1e5;
obj.simulation.reportThreshold = 1e-6; % relative to normalized values, even if normalizedSpotIntensity = false
obj.simulation.mosaicityDistribution = 'uniform';
obj.simulation.uniformSpotIntensity = false;
obj.simulation.mosaicitySystem = 'abc';
obj.simulation.beamDivergenceDistribution = 'normal';
obj.simulation.beamDivergenceHalfAngle = 0;
obj.simulation.gaussianSpreadHalfAngle = .5;
obj.simulation.current = false;
obj.simulation.faceAlpha = 1;
obj.simulation.displayInDENNIS = true;
obj.simulation.displayLabelsInDENNIS = false;
obj.simulation.image = -1;
obj.simulation.normalizedSpotIntensity = true;

end