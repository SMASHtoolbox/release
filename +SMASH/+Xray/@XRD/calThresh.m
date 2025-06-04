% CALTHRESH - determine background removal threshold for calibration
%
% This method determines the peak-specific background removal thresholds 
% for detectorAuto and the suggested starting global background removal 
% threshold for detectorManual.
%
% Usage:
%   >> obj = calThresh(obj)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calThresh(obj)

%% Input handling

im = obj.detector.image;
assert(~isnumeric(im), 'No detector image')

switch obj.calibration.type
    case 'detectorAuto'
        assert(size(obj.calibration.roi,1)>2,'Invalid ROI');
    case 'detectorManual'
        if ~isnumeric(obj.calibration.processedImage)
            im = obj.calibration.processedImage;
        end
        midPoint = round(numel(im.Grid2)/2);
        obj.calibration.roi = [im.Grid1([1 end])', ...
            im.Grid2([midPoint midPoint])];
    otherwise
        warning('No threshold determination for this calibration type')
        return
end
roi = obj.calibration.roi;

%% Set defaults based on image

imNum = numel(im.Data);
obj.calibration.opts.minRegSize = round(imNum/4.1943e3,-2); % 1000 for a 2048x2048
obj.calibration.opts.minPointDist = round(imNum/2.0972e+05,-1); % 20
obj.calibration.opts.maxPointNum = round(imNum/4.1943e4,-1); % 100

%% Peak/Trough along line

% filter out the low-frequency background and high-frequency noise, taking
% care to avoid edge effects caused by masking

if strcmp(obj.calibration.type, 'detectorAuto')
    zeroInd = im.Data <= 0.05*max(max(im.Data));
    im = replace(im, nan, zeroInd);
    im = replace(im, fillmissing(im.Data,'nearest'), ...
        true(size(im.Data)));
    im = bandpass(im, [1/100 1/10], 'butterworth');
    im = replace(im, 0, zeroInd);
end

% extract signal along roi line

lineFit = polyfit(roi(:,1), roi(:,2), 1);
ext = 0.25*(max(roi(:,1)) - min(roi(:,1)));
xBounds = [max(im.Grid1(1), min(roi(:,1))-ext), ...
    min(im.Grid1(end), max(roi(:,1)+ext))];
x = linspace(xBounds(1),xBounds(2),numel(im.Grid1));
sig = lookup(im, x, polyval(lineFit, x));
sigX = 1:numel(sig);

switch obj.calibration.type
    case 'detectorAuto'

        % correlate roi points to points along the line via an orthogonal
        % projection (solve for projection line, evaluate, and then find closest
        % index (close is good enough))

        m = -1/lineFit(1);
        b = roi(:,2) - (m*roi(:,1));
        projX = (b - lineFit(2)) / (lineFit(1) - m); % image grid point
        projSigX = round(interp1(x, sigX, projX, 'linear')); % index along signal

        % find the peaks closest to the selected points

        peakInd = sigX(islocalmax(sig, 'MinSeparation', numel(sig)/150)); % just some basic quality control
        peakIndDist = abs(peakInd - projSigX);
        [~, closestPeakInd] = min(peakIndDist, [], 2);
        peakInd = peakInd(closestPeakInd);
        assert(numel(unique(peakInd)) == numel(peakInd), ...
            'Failed to find unique peaks across user selection')
        [peakInd, sortInd] = sort(peakInd);

    case 'detectorManual'

        peakInd = sigX(islocalmax(sig, 'MaxNumExtrema', 3));
        if numel(peakInd) < 3
            warning('Failed to auto-determine threshold');
            return
        end

end

% find the associated troughs as the min values between each peak
% this is less likely to cause issues than trough searching and filtering

troughInd = nan(1, numel(peakInd)-1);
for ii = 1:numel(troughInd)
    windInd = sigX > peakInd(ii) & sigX < peakInd(ii+1);
    [~, minLoc] = min(sig(windInd));
    troughInd(ii) = minLoc + find(windInd,1) - 1;
end


%% Threshold determination

troughInd = [troughInd(1), troughInd, troughInd(end)];
threshFrac = obj.calibration.opts.threshFrac;
backVal = max([sig(troughInd(1:end-1));sig(troughInd(2:end))],[],1);
threshold = threshFrac*(sig(peakInd) - backVal) + backVal;

switch obj.calibration.type
    case 'detectorAuto'
        obj.calibration.opts.threshold = threshold;
        obj.calibration.roi = obj.calibration.roi(sortInd,:);
        obj.calibration.processedImage = im;
    case 'detectorManual'
        obj.calibration.opts.threshold = min(threshold);
end

end
