function [gCoords, qCoords] = findPixelCoordinates(obj, varargin)

% output pages are xyz

% parse inputs

qPoints = 'none';
if nargin > 1
    qPoints = varargin{1}; % [pt, xy, reg]
end

% pull out needed variables (and cast to appropriate dimensions)

planePoints = reshape(obj.detector.planePoints, 2, 1, 3);
planeCenter = reshape(obj.detector.location, 1, 1, 3);
grid1 = obj.detector.image.Grid1;
grid2 = obj.detector.image.Grid2;

% determine coordinates of each pixel (have to do manually b/c I use
% texturemap to plot and matlab won't give me the pixel locations)

% I force monotonically uniformly increasing grids during import. The grid values
% start counting from Data(1,1). That's the bottom left of the image for an
% unrotated detector in the main GUI (SMASH flips its vertical axis display 
% so that it's the top left in the Processing GUI)

% define grid vectors and starting point

h_vec = planePoints(1,:,:) - planeCenter;
w_vec = planePoints(2,:,:) - planeCenter;
startPoint = planeCenter - h_vec - w_vec;

% find grid boundaries for normalization, accounting for the fact that
% the pixel locations should be at the grid box centers and that the vector
% tips and tails are at grid box edges

boxBounds1 = [1.5*grid1(1) - 0.5*grid1(2), 1.5*grid1(end) - 0.5*grid1(end-1)];
boxBounds2 = [1.5*grid2(1) - 0.5*grid2(2), 1.5*grid2(end) - 0.5*grid2(end-1)];

% normalize and compute coordinates

[grid1, grid2] = meshgrid(grid1, grid2);
gCoords = computeCoords(grid1, grid2, boxBounds1, boxBounds2, ...
    startPoint, h_vec, w_vec); % [r c xyz]
qCoords = 'none';
if isnumeric(qPoints)
    qPoints = permute(qPoints, [1 3 2]); % [pt reg xy] (so I can input 2D array)
    qCoords = computeCoords(qPoints(:,:,1), qPoints(:,:,2), ...
        boxBounds1, boxBounds2, startPoint, h_vec, w_vec); % [pt reg xyz]
end

end

function coords = computeCoords(x, y, boxBounds1, boxBounds2, ...
    startPoint, h_vec, w_vec)
x = (x - boxBounds1(1))/(boxBounds1(2) - boxBounds1(1));
y = (y - boxBounds2(1))/(boxBounds2(2) - boxBounds2(1));
coords = startPoint + y.*(2*h_vec) + x.*(2*w_vec);
end