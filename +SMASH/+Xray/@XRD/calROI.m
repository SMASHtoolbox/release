% CALROI - select regions of interest for calibrations
%
% This method finds SMASH ROIs for detector and crystal calibrations.
%
% Usage:
%   >> obj = calROI(obj)
%   >> obj = calROI(obj, target)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calROI(obj, varargin)

% parse inputs

fig = nan; ax = nan;
if nargin > 1 && ishandle(varargin{1})
    ax = varargin{1};
end

% user ROI selection

switch obj.calibration.type
    case 'detectorAuto'
        if ~ishandle(ax)
            [fig, ax] = showImage(obj.detector.image);
        end
        roi = SMASH.ROI.selectROI({'points','connected'}, ax);
    case 'detectorManual'
        warning('No roi selection required for detectorManual');
        return
    case 'crystal'
        switch obj.calibration.opts.roiSelect
            case 'auto'
                roi = autoSpotFind(obj);
            case 'manual'
                if ~ishandle(ax)
                    [fig, ax] = showImage(obj.detector.image);
                end
                roi = SMASH.ROI.selectROI({'points','open'}, ax);
                obj.calibration.opts.roiNum = size(roi.Data,1);
        end
end

obj.calibration.roi = roi.Data;

if ishandle(fig)
    close(fig)
end

end

function roi = autoSpotFind(obj)

% downsample image to smaller than limit

sizeLim = 250;

[rSize, cSize] = size(obj.detector.image.Data);
smallR = 1:ceil(rSize/sizeLim):rSize;
smallC = 1:ceil(cSize/sizeLim):cSize;

% find maxima in downsampled image (~0.25 s for 250x250)

[rMax, cMax] = ind2sub([numel(smallR), numel(smallC)],find(...
    islocalmax2(obj.detector.image.Data(smallR,smallC), ...
    'MaxNumExtrema', obj.calibration.opts.roiNum)));

% correlate results back to main image

x = obj.detector.image.Grid1(smallC(cMax));
y = obj.detector.image.Grid2(smallR(rMax));
roi.Data = [x', y];

end

function [fig, ax] = showImage(im)
h = view(im);
fig = h.figure; 
ax = h.axes;
title(ax, ['Select consecutive rings along a representative slice,', ...
    ' starting with the smallest 2θ'])
axis(ax,'equal');
set(fig, 'Position', get(0, 'Screensize'));
end