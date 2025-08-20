% CONVERTFROMOLD - convert old objects for use in updated class
%
% This method converts old objects for use in the most up to date version
% of the class.
%
% Usage:
%   >> obj = convertFromOld(obj);
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = convertFromOld(obj)
if isfield(obj.prediction, 'I_standard')
    obj.prediction.I = obj.prediction.I_standard;
    obj.prediction = rmfield(obj.prediction, 'I_standard');
end
if isfield(obj.prediction, 'I_dmp')
    obj.prediction = rmfield(obj.prediction, 'I_dmp');
end
if isfield(obj.externalUserData, 'min_I_dmp_show')
    obj.externalUserData.min_I_show = obj.externalUserData.min_I_dmp_show;
    obj.externalUserData = rmfield(obj.externalUserData, 'min_I_dmp_show');
end
if isfield(obj.detector, 'imageHistory')
    if ~isfield(obj.detector.imageHistory, 'prereversemask')
        obj.detector.imageHistory.prereversemask = ...
            obj.detector.imageHistory.premask;
    end
end
if isfield(obj.detector, 'image')
    if ~isnumeric(obj.detector.image)
        cmap = parula;
        obj.detector.image.GraphicOptions.ColorMap = cmap;
        fieldList = {'original', 'lastsave', 'precrop', 'prebackground', ...
            'premask', 'prescale', 'preccfilter', 'presmooth', ...
            'prebandpassfilter'};
        for ii = 1:numel(fieldList)
            if ~isnumeric(obj.detector.imageHistory.(fieldList{ii}))
                obj.detector.imageHistory.(fieldList{ii}).GraphicOptions. ...
                    ColorMap = cmap;
            end
        end
    end
end
if ~isfield(obj.source, 'K')
    obj.source.K = 0.5;
end
if ~isfield(obj.source, 'twoThetaM')
    obj.source.twoThetaM = 0;
end
if ~isfield(obj.prediction, 'Lorentz')
    obj.prediction.Lorentz = 'image';
end
if ~isfield(obj.source, 'lambdaDistribution')
    obj = changeObject(obj, 'source', 'lambdaDistribution', 0.01);
    obj = changeObject(obj, 'source', 'lambda', mean(obj.source.lambda));
end
if isfield(obj.prediction, 'spotLocations')
    if iscell(obj.prediction.spotLocations)
        obj = generatePrediction(obj);
    end
end
if ~isprop(obj, 'simulation')
    obj = setSimulationDefaults(obj);
end
if ~isfield(obj.results, 'average')
    obj = changeObject(obj, 'results', 'average', true);
end
if ~isfield(obj.results, 'inverseLorentz')
    obj = changeObject(obj, 'results', 'inverseLorentz', false);
end
obj = changeObject(obj, 'crystal', 'locationreference', ...
    obj.crystal.location);
obj = changeObject(obj, 'crystal', 'orientationreference', ...
    obj.crystal.orientation);
obj = changeObject(obj, 'source', 'locationreference', ...
    obj.source.location);
obj = changeObject(obj, 'source', 'rotatereference', ...
    obj.source.rotate);
obj = changeObject(obj, 'detector', 'locationreference', ...
    obj.detector.location);
obj = changeObject(obj, 'detector', 'orientationreference', ...
    obj.detector.orientation);

if ~isfield(obj.crystal, 'orientationSystem')
    obj.crystal.orientationSystem = 'xyz';
end

if ~isfield(obj.simulation, 'normalizedSpotIntensity')
    obj.simulation.normalizedSpotIntensity = true;
end

if ~isfield(obj.crystal, 'lengthsReference')
    obj.crystal.lengthsReference = obj.crystal.lengths;
end
if ~isfield(obj.crystal, 'volumeRatio')
    obj.crystal.volumeRatio = prod(obj.crystal.lengths) / ...
        prod(obj.crystal.lengthsReference);
end
if ~isfield(obj.prediction, 'combinationTolerance')
    obj.prediction.combinationTolerance = 0.001;
end

if ~isprop(obj, 'calibration') || isempty(obj.calibration)
    obj = changeObject(obj, 'calibration', 'type', 'detectorAuto');
end

if contains(obj.simulation.mosaicitySystem, 'coord')
    obj.simulation.mosaicitySystem = 'xyz';
elseif contains(obj.simulation.mosaicitySystem, 'crystal')
    obj.simulation.mosaicitySystem = 'abc';
end
    
if isfield(obj.calibration.opts, 'gaPopulation')
    obj.calibration.opts = rmfield(obj.calibration.opts, 'gaPopulation');
end
if ~isfield(obj.calibration.opts, 'gaOpts') || ...
        ~isa(obj.calibration.opts.gaOpts, 'optim.options.GaOptions')
    obj = changeObject(obj, 'calibration', 'opts', 'gaOpts', 'default');
end