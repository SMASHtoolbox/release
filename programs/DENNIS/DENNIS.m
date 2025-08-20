% DENNIS (Diffraction Experiment desigN and aNalysIS)
%
% Journal papers: https://doi.org/10.1088/1748-0221/19/07/P07030
%                 https://doi.org/10.1063/5.0267671
%
% Created by Nathan Brown (Sandia National Laboratories)
%
function DENNIS

%% Main GUI

% generate GUI and make category buttons

fontSize = 12;

db = SMASH.MUI.DialogPlot('FontSize', fontSize);
db.Name = 'Diffraction Experiment desigN and aNalysIS';

h_categories = addblock(db, 'Text', 'Options:');
h_crystal = addblock(db, 'button', 'Crystal');
h_source = addblock(db, 'button', 'X-ray Source');
h_detector = addblock(db, 'button', 'Detector');
h_calibration = addblock(db, 'button', 'Calibration');
h_prediction = addblock(db, 'button', 'Prediction');
h_simulation = addblock(db, 'button', 'Simulation');
h_analysis = addblock(db, 'button', 'Analysis');
h_import = addblock(db, 'custom', {'button', 'button'}, {'Import', ...
    'Export'});

% set callbacks

[~, basePath] = strtok(fliplr(mfilename('fullpath')),'/\');
basePath = fliplr(basePath);
path1 = fullfile(basePath, 'helpers');
path2 = fullfile(basePath, 'dennisCallbacks');
path3 = fullfile(basePath, 'sharedCallbacks');
addpath(path1, path2, path3);

set(h_crystal, 'Callback', @crystalDlg);
set(h_source, 'Callback', @sourceDlg);
set(h_detector, 'Callback', @detectorDlg);
set(h_calibration, 'Callback', @calibrationDlg);
set(h_prediction, 'Callback', @predictionDlg);
set(h_simulation, 'Callback', @simulationDlg);
set(h_analysis, 'Callback', @analysisDlg);
set(h_import(1), 'Callback', @importDlg);
set(h_import(2), 'Callback', @exportDlg);
set(db.Figure, 'CloseRequestFcn', @closeDennis);

% edit button and text sizes

set(h_categories, 'FontSize', 18);
set(h_categories, 'FontWeight', 'Bold');
pos = get(h_categories, 'Position');
vertChange = 10;
pos(4) = pos(4) + vertChange;
pos(2) = pos(2) + vertChange;
set(h_categories, 'position', pos);

importLoc = get(h_import(1), 'position');
exportLoc = get(h_import(2), 'position');
newWidth = exportLoc(3) + exportLoc(1) - importLoc(1);

for ii = length(db.ControlPanel.Children)-1:-1:3
    newPos = get(db.ControlPanel.Children(ii), 'position');
    newPos(3) = newWidth;
    set(db.ControlPanel.Children(ii), 'position', newPos);
end

% customize figure toolbar

hTool = findobj(db.Figure,'Type','uitoolbar');
if ~isempty(hTool)
    uitoggletool('Parent', hTool, 'Tag', 'rotate', ...
        'ToolTipString', 'Rotate', 'Cdata', rotateGraphic, ...
        'ClickedCallBack', @rotateCallback);
    hTool.Children = [hTool.Children(2:12); hTool.Children(1); ...
        hTool.Children(13:end)];
    delete(hTool.Children([1,3,4,5,6,7,16]))
    hTool.Children(5).Separator = 'on';
    hTool.Children(end).Separator = 'off';
else
    warning('Can''t add rotation button to toolbar')
end

% try adding axes toolbar

try
    axtoolbar(db.Axes, 'default');
catch
end

% make GUI large and put in center

set(db.Figure,'Units','normalized');
set(db.Figure, 'Position', [0.10 0.10 0.80 0.80]);
movegui(db.Figure, 'center');

% adjust control panel

newPos = get(db.ControlPanel, 'position');
newPos(2) = newPos(2) - 2*vertChange;
newPos(4) = newPos(4) + vertChange;
set(db.ControlPanel, 'position', newPos);

% set GUI view

ax = get(db.Figure, 'CurrentAxes');
view(ax, 21, 13);
axis(ax, 'equal');
box(ax, 'off');
hold(ax, 'on');
xlabel('x (mm)'); ylabel('y (mm)'); zlabel('z (mm)');

% set GUI colormap

% colormap(ax, jet(64)); % SMASH default but not perceptually uniform
colormap(ax, parula);

% finish GUI

finish(db);

% initiate GUI operation

db.Figure.UserData = SMASH.Xray.XRD;
updatePlotPredictionAnalysis(db.Figure);

end