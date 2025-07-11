function analysisDlg(src, event)

%% dialog box creation

% basics

mainFigure = ancestor(src, 'figure', 'toplevel');
[db, ex] = createDlg(mainFigure, 'analysisDlg', 'dialogplot');
if ex
    return
end

db.Name = 'Powder Diffraction Image Analysis';

% handles

h_label = addblock(db, 'text', 'Parameters');
h_edit = addblock(db, 'edit', 'Res (deg)');
h_check = addblock(db, 'check', ' Average along arc?'); 

% re-size and place dialog

set(db.Figure, 'Units', 'normalized')
set(db.Figure, 'Position', [0.1 0.1 0.6 0.5]);
movegui(db.Figure, 'center');
set(db.Figure, 'Units', 'pixels')

% determine scaling parameters

[p, f] = determineScaling;

%% re-positioning

set(h_label, 'FontSize', 18*f);
set(h_edit, 'FontSize', 12*f);
set(h_check, 'FontSize', 12*f);

figurePos = get(db.Figure, 'Position');
startHeight = figurePos(4) - (250/450)*figurePos(4);

cpWidth = 200*p;
pos = db.ControlPanel.Position;
pos(2:2:4) = figurePos(2:2:4);
pos(3) = cpWidth;
db.ControlPanel.Position = pos;

pos = db.PlotPanel.Position;
widthChange = cpWidth - pos(1);
pos(1) = cpWidth;
pos(3) = pos(3) - widthChange;
db.PlotPanel.Position = pos;

set(h_label, 'Position', [10*p startHeight 200*p 40*p])
set(h_edit(1), 'Position', [10*p startHeight-50*p 200*p 40*p]);
set(h_edit(2), 'Position', [10*p startHeight-80*p 74*p 40*p]);
set(h_check, 'Position', [10*p startHeight-120*p 200*p 40*p]);

%% callbacks and defaults

% defaults

obj = get(mainFigure, 'UserData');
set(h_edit(2), 'string', num2str(obj.results.thetaResolution));
set(h_check, 'Value', obj.results.average);

xlabel(db.Axes, '2\theta (deg)')
ylabel(db.Axes, 'Normalized Intensity (au)')
set(db.Axes, 'FontSize', 16*f)
hold(db.Axes, 'on')

if ~isnumeric(obj.detector.image)
    updatePlotPredictionAnalysis(mainFigure, 'results');
else
    importDetectorImage(mainFigure);
    obj = get(mainFigure, 'UserData');
    if isnumeric(obj.detector.image)
        close(db.Figure)
        return
    end
end

% callbacks

set(h_edit(2), 'Callback', {@analysisEdit, mainFigure, h_edit});
set(h_check, 'Callback', {@analysisCheck, mainFigure, h_check});

end

function analysisEdit(src, event, mainFigure, h_edit)

newVal = editExtract(h_edit);
obj = get(mainFigure, 'UserData');

if isnan(newVal)
    newVal = obj.results.thetaResolution;
end

updateFromEdit(mainFigure, newVal, 'results', 'thetaResolution', ...
    h_edit, false);

end

function analysisCheck(src, event, mainFigure, h_check)

newVal = logical(get(h_check, 'Value'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'results', 'average', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'results');

end