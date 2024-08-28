function coords = findPixelCoordinates(obj)

% pull out needed variables (and cast into appropriate dimensions)

planePoints = reshape(obj.detector.planePoints, 2, 1, 3);
planeCenter = reshape(obj.detector.location, 1, 1, 3);
grid1 = obj.detector.image.Grid1;
grid2 = obj.detector.image.Grid2;

% determine coordinates of each pixel (have to do manually b/c I use
% texturemap to plot and matlab won't give me the pixel locations)

% I force monotonically increasing grids during import. The grid values
% start counting from Data(1,1). That's the bottom left of the image for an
% unrotated detector in the main GUI (SMASH flips its vertical axis display 
% so that it's the top left in the Processing GUI)

% define grid vectors and starting point

h_vec = planePoints(1,:,:) - planeCenter;
w_vec = planePoints(2,:,:) - planeCenter;
startPoint = planeCenter - h_vec - w_vec;

% normalize the grid values along the vectors, accounting for the fact that
% the pixel locations should be at the grid box centers and that the vector
% tips and tails are at grid box edges

boxBounds = [1.5*grid1(1) - 0.5*grid1(2), 1.5*grid1(end) - 0.5*grid1(end-1)];
grid1 = (grid1 - boxBounds(1))/(boxBounds(2) - boxBounds(1));
boxBounds = [1.5*grid2(1) - 0.5*grid2(2), 1.5*grid2(end) - 0.5*grid2(end-1)];
grid2 = (grid2 - boxBounds(1))/(boxBounds(2) - boxBounds(1));

% determine the coordinates of each grid point

[grid1, grid2] = meshgrid(grid1, grid2);
coords = startPoint + grid2.*(2*h_vec) + grid1.*(2*w_vec);

end