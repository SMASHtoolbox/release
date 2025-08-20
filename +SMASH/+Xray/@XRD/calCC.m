% CALCC - find connected component regions for calibration
%
% This method finds connected component regions for detector and crystal
% calibrations. It must be run after calThresh for 
% detectorAuto, after background removal for detectorManual, and after 
% calROI for crystal.
%
% Usage:
%   >> obj = calCC(obj)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calCC(obj)

% input parsing

im = obj.detector.image;
assert(~isnumeric(im), 'No detector image')
if ~strcmp(obj.calibration.type, 'detectorManual')
    assert(~isempty(obj.calibration.roi), 'No ROI detected');
end

% code

switch obj.calibration.type
    case 'detectorAuto'

        % iteratively background and cc filter at each roi point to find
        % the associated cc region

        im = obj.calibration.processedImage;
        assert(~isnumeric(im), 'No filtered detector image')
        roi = obj.calibration.roi;
        thresh = obj.calibration.opts.threshold;
        regSize = obj.calibration.opts.minRegSize;
        obj.calibration.cc = iterativeCCFilter(im, roi, thresh, regSize);

    case 'detectorManual'

        % apply global cc to image based on region size

        if ~isnumeric(obj.calibration.processedImage)
            im = obj.calibration.processedImage;
        end
        [~, obj.calibration.cc] = ccFilter(im, ...
            obj.calibration.opts.minRegSize, 4);

    case 'crystal'

        % iteratively background and cc filter at each roi point to find
        % the associated cc region

        roi = obj.calibration.roi;
        thresh = obj.calibration.opts.threshFrac * lookup(im, ...
            roi(:,1), roi(:,2));
        regSize = numel(im.Data)/2e5;
        obj.calibration.cc = iterativeCCFilter(im, roi, thresh, regSize);

end

end

function cc = iterativeCCFilter(im, roi, thresh, regSize)

cc = struct('Connectivity', 4, 'ImageSize', size(im.Data), ...
    'NumObjects', size(roi,1));
cc.PixelIdxList = {};
cc.NumPixels = [];
for ii = 1:cc.NumObjects
    imBack = removeBackground(im, thresh(ii));
    [~, ccii] = ccFilter(imBack, regSize, cc.Connectivity);
    smallestDist = inf;
    for jj = 1:ccii.NumObjects
        ptsInd = ccii.PixelIdxList{jj};
        [rInd, cInd] = ind2sub(cc.ImageSize, ptsInd);
        dist = min(vecnorm(roi(ii,:) - ...
            [im.Grid1(cInd)' im.Grid2(rInd)],2,2));
        if dist < smallestDist
            smallestDist = dist;
            ccInd = jj;
        end
    end
    cc.PixelIdxList = [cc.PixelIdxList, ccii.PixelIdxList(ccInd)];
    cc.NumPixels = [cc.NumPixels, ccii.NumPixels(ccInd)];
end

end
