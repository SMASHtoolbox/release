% CALPOI - find points of interest for calibration
%
% This method finds points of interest for detector and crystal
% calibrations. It must be run after calCC unless applying a
% crystal calibration with the 'exact' poi method.
%
% Usage:
%   >> obj = calPOI(obj)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calPOI(obj, varargin)

% input parsing

if nargin > 1 % advanced users only, keep undocumented
    obj.calibration.poi = varargin{1};
    return
end

if ~isfield(obj.calibration.opts, 'poiType') || ...
        ~strcmp(obj.calibration.opts.poiType, 'exact')
    assert(~isempty(obj.calibration.cc), 'No connected components')
else
    assert(~isempty(obj.calibration.roi), 'No ROI')
end

% code

if contains(obj.calibration.type, 'detector')
    obj.calibration.poi = findRingPoints(obj.detector.image, ... % use raw image, not filtered
        obj.calibration.cc, obj.calibration.opts.minPointDist, ...
        obj.calibration.opts.maxPointNum, ...
        obj.calibration.opts.intCutoff);
else
    if strcmp(obj.calibration.opts.poiType, 'exact')
        obj.calibration.poi = obj.calibration.roi;
        obj.calibration.poiIntensity = lookup(obj.detector.image, ...
            obj.calibration.poi(:,1), obj.calibration.poi(:,2));
    else
        [obj.calibration.poi, obj.calibration.poiIntensity] = ...
            findSpotPoints(obj.detector.image, obj.calibration.cc, ...
            obj.calibration.opts.poiType);
    end
end

end

function peakPoints = findRingPoints(im, cc, minPointDist, maxNum, cutoff)

% start with brightest spot in region and then loop through and iteratively
% find next-brightest spot that is min distance away from all other spots
% in region, until either the max number of spots is found or the
% next-brightest spot is below the intensity threshold

peakPoints = nan(maxNum, 2, cc.NumObjects);

for ii = 1:cc.NumObjects
    ptsind = cc.PixelIdxList{ii};
    [ptsr, ptsc] = ind2sub(cc.ImageSize, ptsind);
    vals = im.Data(ptsind);
    sortVals = sort(vals);
    cutoffVal = sortVals(floor(cutoff*cc.NumPixels(ii)));
    vals(vals < cutoffVal) = 0;
    maxloc = nan(maxNum,2);
    [~, idxMax] = max(vals);
    maxloc(1,:) = [im.Grid1(ptsc(idxMax)), im.Grid2(ptsr(idxMax))];
    idxClose = sqrt((ptsr(idxMax) - ptsr).^2 + ...
        (ptsc(idxMax) - ptsc).^2) < minPointDist;
    vals(idxClose) = 0;
    jj = 2;
    while any(vals) && jj <= maxNum
        [~, idxMax] = max(vals);
        maxloc(jj,:) = [im.Grid1(ptsc(idxMax)), im.Grid2(ptsr(idxMax))];
        idxClose = sqrt((ptsr(idxMax) - ptsr).^2 + ...
            (ptsc(idxMax) - ptsc).^2) < minPointDist;
        vals(idxClose) = 0;
        jj = jj + 1;
    end
    peakPoints(1:maxNum,1,ii) = maxloc(:,1); % [pt, xy, region]
    peakPoints(1:maxNum,2,ii) = maxloc(:,2);
end

end

function [spotPoints, spotIntensities] = findSpotPoints(im, cc, poiType)

% loop through cc regions and pick out either the weighted mean or the
% maximum value

spotPoints = nan(cc.NumObjects,2); % [pt, xy]
spotIntensities = nan(cc.NumObjects,1);
for ii = 1:cc.NumObjects
    ptsInd = cc.PixelIdxList{ii};
    w = im.Data(ptsInd);
    spotIntensities(ii) = mean(w); % already thresholding in cc determination
    [r, c] = ind2sub(cc.ImageSize, ptsInd);
    switch poiType
        case 'mean'
            spotPoints(ii,:) = sum(w.*[im.Grid1(c)', im.Grid2(r)])/sum(w);
        case 'max'
            [~, maxInd] = max(w);
            spotPoints(ii,:) = [im.Grid1(c(maxInd)), im.Grid2(r(maxInd))];
    end
end

end

