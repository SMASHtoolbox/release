% GENERATERESULTS - integrate 2D diffraction pattern
%
% This method integrates the processed 2D diffraction pattern into a
% standard 1D intensity vs 2θ plot
%
% Usage:
%   >> obj = generateResults(obj)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
% updated June, 2023 by Nathan Brown
%
function obj = generateResults(obj)

% update object

obj = convertFromOld(obj);

% delete results in case something goes wrong

obj = deletePredictionAndResults(obj, 'r');

% check that we have data

if isnumeric(obj.detector.image)
    return
end

% pull out needed variables (and cast into appropriate dimensions)

coords = findPixelCoordinates(obj);
crystalCenter = reshape(obj.crystal.location, 1, 1, 3);
cdata = obj.detector.image.Data;
s0 = ones(size(cdata));
s0 = cat(3, s0*obj.source.s0(1), s0*obj.source.s0(2), s0*obj.source.s0(3));
thetaResolution = obj.results.thetaResolution;

% compute theta values

v = coords - crystalCenter;
twoTheta = acosd(dot(v,s0,3) ./ (vecnorm(v,2,3) .* vecnorm(s0,2,3)));

% bin and sum intensities at each twoTheta

[N, edges, bin] = histcounts(twoTheta, ...
    0:thetaResolution:180+thetaResolution);
rIntensity = accumarray(bin(:), cdata(:));

% apply optional calculations to intensity

if obj.results.average % take average
    countVal = ones(size(cdata));
    countVal(isnan(cdata) | cdata <= 0) = 0; % don't count nans and zeros
    binNumA = accumarray(bin(:), countVal(:));
    rIntensity = rIntensity ./ binNumA;
end

if obj.results.inverseLorentz % apply inverse LP correction
    warning('Not currently functional')
end

% subtract out background and normalize

originalMin = min(rIntensity(rIntensity > 1e-6));
normIntensity = rIntensity - originalMin;
normIntensity(isnan(normIntensity) | isinf(normIntensity) | normIntensity <= 0) = 0;
finalMax = max(normIntensity);
normIntensity = normIntensity/finalMax;

% register intensity with theta

twoTheta = edges(1:end-1) + diff(edges)/2;
goodInd = twoTheta > 0 & twoTheta < 180;
twoTheta = [0, twoTheta(goodInd), 180];
rawIntensity = zeros(size(N));
rawIntensity(1:max(max(bin))) = rIntensity;
rawIntensity = [0, rawIntensity(goodInd), 0];
normalizedIntensity = zeros(size(N));
normalizedIntensity(1:max(max(bin))) = normIntensity;
normalizedIntensity = [0, normalizedIntensity(goodInd), 0];
if obj.results.average
    binNum = zeros(size(N));
    binNum(1:max(max(bin))) = binNumA;
    binNum = [0, binNum(goodInd), 0];
end

% save results

obj.results.twoTheta = twoTheta;
obj.results.rawIntensity = rawIntensity;
obj.results.normalizedIntensity = normalizedIntensity;
obj.results.normalization.binNum = nan;
obj.results.normalization.originalMin = originalMin;
obj.results.normalization.finalMax = finalMax;
if obj.results.average
    obj.results.normalization.binNum = binNum;
end

end