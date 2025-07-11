function calibrationDlg(src, event)

%% input parsing

mainFigure = ancestor(src, 'figure', 'toplevel');

% check for open calibration dlgs

if isappdata(mainFigure, 'calCrystalDlg')
    db = getappdata(mainFigure, 'calCrystalDlg');
    if isvalid(db) && ~isempty(db.Axes)
        figure(db.Figure);
        return
    end
elseif isappdata(mainFigure, 'calDetectorManualDlg')
    db = getappdata(mainFigure, 'calDetectorManualDlg');
    if isvalid(db) && ~isempty(db.Axes)
        figure(db.Figure);
        return
    end
end

% check for ga function

if ~license('test', 'GADS_Toolbox')
    errordlg('MATLAB Global Optimization Toolbox required for calibration')
    return
end

% check for image

obj = get(mainFigure, 'UserData');
if isnumeric(obj.detector.image)
    errordlg('Load and process detector image prior to calibration')
    return
end

%% dialog box creation

[db, ex] = createDlg(mainFigure, 'calibrationDlg', 'dialog');
if ex
    return
end

db.Name = 'Calibration Type';

h_button = addblock(db, 'custom', {'button', 'button', 'button'}, ...
    {'Detector (auto)', 'Detector (manual)', 'Crystal'});

% determine scaling parameters

GUIHeight = 60;
[p, f] = determineScaling(GUIHeight,.85);

% re-size whole GUI

pos = get(db.Handle, 'Position');
pos(3) = 420*p;
pos(4) = GUIHeight*p;
set(db.Handle, 'Position', pos);

%% button edits

% change batch fonts

for ii = 1:numel(h_button)
    set(h_button(ii), 'FontSize', 12*f);
end

% edit position

set(h_button(1), 'position', p*[10 10 150 40]);
set(h_button(2), 'position', p*[170 10 150 40]);
set(h_button(3), 'position', p*[330 10 70 40]);

% set callbacks

set(h_button(1), 'Callback', {@calDetectorAuto, mainFigure});
set(h_button(2), 'Callback', {@calDetectorManualDlg, mainFigure});
set(h_button(3), 'Callback', {@calCrystalDlg, mainFigure});

movegui(db.Handle, 'center')

end

%% callbacks

function calDetectorAuto(src, event, mainFigure)
% mainFigure = ancestor(src,'figure','toplevel'); % not reliable
close(ancestor(src,'figure'));
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'type', 'detectorAuto');
obj = calROI(obj);
obj = calThresh(obj);
obj = calCC(obj);
obj = calPOI(obj);
obj = calSolve(obj);
set(mainFigure, 'UserData', obj)
updatePlotPredictionAnalysis(mainFigure);
end




