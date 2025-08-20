% GENERATEPREDICTIONFIGURE - generate 2D figure of prediction on detector
%
% This method plots the single-crystal or powder prediction on the detector
% image in a 2D figure and outputs the figure handle.
%
% Usage:
%   >> h = generatePredictionFigure(obj);
%   >> h = generatePredictionFigure(obj, XDir, YDir)
%       --> optionally specify the XDir and YDir as 'normal' or 'reverse'
%
% created August, 2024 by Nathan Brown (Sandia National Laboratories)
%
function h = generatePredictionFigure(obj, varargin)

% parse inputs

obj = generatePrediction(obj);
assert(~isempty(obj.prediction.spotLocations), 'Nothing to plot');

noImageFlag = false;
if isnumeric(obj.detector.image)
    im = SMASH.ImageAnalysis.Image(1:100, 1:100, zeros(100,100));
    noImageFlag = true;
else
    im = obj.detector.image;
end

xdir = 'normal';
ydir = 'normal';
if nargin > 1
    xdir = varargin{1};
    if nargin > 2
        ydir = varargin{2};
    end
end

% pull out detector and spot information

spotLoc = obj.prediction.spotLocations;
planePoints = obj.detector.planePoints;
planeCenter = obj.detector.location;
grid1 = im.Grid1;
grid2 = im.Grid2;
planeVecs = planePoints - planeCenter;
startPoint = planeCenter - planeVecs(1,:) - planeVecs(2,:);
planeVecs = planeVecs./vecnorm(planeVecs,2,2);
x = dot(spotLoc - startPoint, ...
    repmat(planeVecs(2,:),size(spotLoc,1),1,size(spotLoc,3)),2);
y = dot(spotLoc - startPoint, ...
    repmat(planeVecs(1,:),size(spotLoc,1),1,size(spotLoc,3)),2);
psize = obj.detector.size./[numel(grid2) numel(grid1)];
x = interp1(1:numel(grid1), grid1, x/psize(2)) + 0.5;
y = interp1(1:numel(grid2), grid2, y/psize(1)) + 0.5; % +0.5 necessary b/c view() actually starts at 0.5,0.5 instead of 0,0

% plot and export

im.GraphicOptions.XDir = xdir;
im.GraphicOptions.YDir = ydir;
h = view(im);
axis(h.axes, 'equal');
hold(h.axes,'on');

switch obj.prediction.type
    case 'single-crystal'
        plot(h.axes, x, y, 'r*', 'markersize', 5);
    case 'powder'
        plot(h.axes, permute(x,[3 1 2]), permute(y, [3 1 2]), ...
            'r-', 'LineWidth', 2)
end

if noImageFlag
    colormap(h.axes, 'gray')
    caxis([-.5 .1]);
end

title(h.axes,'');
h = h.figure;

end