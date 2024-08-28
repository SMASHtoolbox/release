% This function requires 2018b or later Image Processing Toolbox!

function [ind, diam] = drawCircle(im, ax)

% draw circle and let user edit it

xlims = xlim(ax);
ylims = ylim(ax);
x = diff(xlims)/2 + xlims(1);
y = diff(ylims)/2 + ylims(1);
rad = min(diff(xlims), diff(ylims))/2;
roi = drawcircle(ax, 'Color', 'w', 'LineWidth', 1.5, 'Center', [x y], ...
    'Radius', rad, 'FaceAlpha', 0, 'DrawingArea', 'unlimited');
pause; % resumes upon any key press (could use input to force Enter to be the key)
roi.Visible = 'off';

% determine index of points inside circle and circle diameter

[x, y] = meshgrid(im.Grid1, im.Grid2);
dist = sqrt((x-roi.Center(1)).^2 + (y-roi.Center(2)).^2);
ind = dist <= roi.Radius;

diam = 2*roi.Radius;

end