% FINDSPOTLOCATIONS - find where spots intersect the detector plane
%
% This method finds where diffraction spots intersect the detector
%
% Usage:
%   >> obj = findSpotLocations(obj)
%   >> obj = findSpotLocations(obj, 'simulation')
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = findSpotLocations(obj, varargin)

simFlag = false;
if nargin > 1 && strcmpi(varargin{1}(1), 's')
    simFlag = true;
end

% extract what you need from the object

planeLoc = obj.detector.location;
crystalLoc = obj.crystal.location;

if ~simFlag
    s = obj.prediction.s;
    predictionType = obj.prediction.type;
end

% perform calculations needed for both powder and single-crystal

[planeNormal, dist, n] = computePlaneValues(obj);

% perform calculations specific to prediction/simulation type

if simFlag

    % find where spots hit the detector

    [~, badInd, obj.simulation.xy] = findIntersection(...
        obj.simulation.s, planeNormal, planeLoc, crystalLoc, dist, n, ...
        obj.detector.image);

    % eliminate stuff that doesn't hit the detector

    obj.simulation.lambdaSol(badInd) = [];
    obj.simulation.hkl(badInd,:) = [];

    % eliminate unneeded variables

    obj.simulation.s = 'deleted to save space';

elseif strcmpi(predictionType, 'powder')

    % find spot locations

    [spotLoc, badInd] = findIntersection(...
            s, planeNormal, planeLoc, crystalLoc, dist, n, ...
            obj.detector.image);

    % remove twoThetas that don't make it to the detector at all

    completeDeleteInd = sum(~badInd,3) < 2; % all() won't catch twoTheta with just one intersection
    spotLoc(completeDeleteInd,:,:) = [];

    obj.prediction.s(completeDeleteInd) = [];
    obj.prediction.twoTheta(completeDeleteInd) = [];
    obj.prediction.I(completeDeleteInd) = [];
    obj.prediction.hkl(completeDeleteInd,:) = [];
    obj.prediction.d(completeDeleteInd) = [];

    if ~isempty(obj.prediction.F)
        obj.prediction.F_abs(completeDeleteInd) = [];
        obj.prediction.F(completeDeleteInd) = [];
    end

    if ~isempty(obj.prediction.m)
        obj.prediction.m(completeDeleteInd) = [];
    end

    % NaN out the unplotted portions of twoThetas that do make it (better
    % for plotting)

    spotLoc(repmat(badInd(~completeDeleteInd,:,:),1,3,1)) = nan;
    obj.prediction.spotLocations = spotLoc;
    

elseif strcmpi(predictionType, 'single-crystal')

    % find spots and eliminate anything that doesn't hit the detector

    [spotLoc, badInd] = findIntersection(s, ...
        planeNormal, planeLoc, crystalLoc, dist, n, obj.detector.image);
    s(badInd,:) = []; % here we can just get rid of them - don't need to carry nans
    spotLoc(badInd,:) = [];

    % populate object

    obj.prediction.s = s;
    obj.prediction.spotLocations = spotLoc;

    obj.prediction.lambdaSol(badInd) = [];
    obj.prediction.hkl(badInd,:) = [];

end

end
