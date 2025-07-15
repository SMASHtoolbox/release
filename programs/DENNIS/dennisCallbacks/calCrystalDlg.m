function calCrystalDlg(src, event, mainFigure)

%% dialog box creation

% basics

[db, ex] = createDlg(mainFigure, 'calCrystalDlg', 'dialogplot');
if ex
    return
end

close(ancestor(src,'figure'));
db.Name = 'Crystal Calibration';

% handles

h_poiLabel = addblock(db, 'text', 'POI Selection');
h_roiText = addblock(db, 'text', 'ROI Selection:');
h_roiRadio = addblock(db, 'radio', {'Auto', 'Manual'});
h_roiEdit = addblock(db, 'edit', 'ROI Num:');
h_poiText = addblock(db, 'text', 'POI Selection:');
h_poiRadio = addblock(db, 'radio', {'Mean', 'Max', 'Exact'});
% h_poiButton = addblock(db, 'button', 'Find');

h_calLabel = addblock(db, 'text', 'Calibration');
h_calSizeEdit = addblock(db, 'edit', 'Pop Size:');
h_calBoundsEdit = addblock(db, 'custom', {'edit','edit','edit','edit'}, ...
    {'± Rx', '± Ry', '± Rz', '± V'});
h_calRadio = addblock(db, 'radio', {'xyz', 'abc'});
h_calButton = addblock(db, 'button', 'Solve');

% initial sizing

dbPos = [0.1 0.1 0.5 0.4];
GUIHeightRaw = 800;
cpWidth = 325;
movegui(db.Figure, 'center');

% determine scaling

[p, f] = determineScaling(GUIHeightRaw, 0.85);
set(db.Figure, 'Units', 'normalized');
set(db.Figure, 'Position', dbPos);
set(db.Figure, 'Units', 'pixels');
GUIHeight = GUIHeightRaw*p;
cpWidth = cpWidth*p;

posC = get(db.ControlPanel, 'position');
posC(4) = GUIHeight;
set(db.ControlPanel, 'position', posC);
posP = get(db.PlotPanel, 'position');
posP(4) = GUIHeight;
set(db.PlotPanel, 'position', posP);
posF = get(db.Figure, 'position');
posF(4) = GUIHeight;
set(db.Figure, 'position', posF);

%% fonts and positions

% font sizes

labelFontSize = 18*f;
textFontSize = 12*f;
editFontSize = 12*f;

set(h_poiLabel, 'FontSize', labelFontSize);
set(h_poiLabel, 'FontWeight', 'bold');
set(h_calLabel, 'FontSize', labelFontSize);
set(h_calLabel, 'FontWeight', 'bold');

set(h_roiText, 'FontSize', textFontSize);
set(h_poiText, 'FontSize', textFontSize);
set(h_calButton, 'FontSize', textFontSize);

for ii = 1:8
    if ii < 3
        set(h_roiRadio(ii), 'FontSize', editFontSize);
        set(h_calRadio(ii), 'FontSize', editFontSize);
        set(h_roiEdit(ii), 'FontSize', editFontSize);
        set(h_calSizeEdit(ii), 'FontSize', editFontSize);
    end
    if ii < 4
        set(h_poiRadio(ii), 'FontSize', editFontSize);
    end
    set(h_calBoundsEdit(ii), 'FontSize', editFontSize);
end

% gui shape and size (important this happens after font sizes)

figurePos = get(db.Figure, 'Position');
startHeight = figurePos(4) - 100*p;

pos = db.ControlPanel.Position;
pos([2 4]) = figurePos([2 4]);
pos(3) = cpWidth;
db.ControlPanel.Position = pos;

pos = db.PlotPanel.Position;
widthChange = cpWidth - pos(1);
pos(1) = cpWidth;
pos(3) = pos(3) - widthChange;
db.PlotPanel.Position = pos;

% positions

set(h_poiLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_roiText, 'Position', [10*p startHeight-40*p 110*p 50*p]);
set(h_roiRadio(1), 'Position', [115*p startHeight-15.5*p 60*p 30*p])
set(h_roiRadio(2), 'Position', [175*p startHeight-15.5*p 80*p 30*p])
set(h_roiEdit(1), 'Position', [10*p startHeight-60*p 75*p 30*p])
set(h_roiEdit(2), 'Position', [85*p startHeight-50*p 60*p 30*p])
set(h_poiText, 'Position', [10*p startHeight-120*p 110*p 50*p]);
set(h_poiRadio(1), 'Position', [115*p startHeight-(120-24.5)*p 70*p 30*p])
set(h_poiRadio(2), 'Position', [185*p startHeight-(120-24.5)*p 60*p 30*p])
set(h_poiRadio(3), 'Position', [245*p startHeight-(120-24.5)*p 70*p 30*p])

startHeight = startHeight-170*p;
set(h_calLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_calSizeEdit(1), 'Position', [10*p startHeight-30*p 75*p 30*p])
set(h_calSizeEdit(2), 'Position', [85*p startHeight-20*p 60*p 30*p])
offset = 70*p;
set(h_calBoundsEdit(1), 'Position', [10*p startHeight-offset 60*p 30*p]);
set(h_calBoundsEdit(2), 'Position', [10*p startHeight-offset-20*p 60*p 30*p]);
set(h_calBoundsEdit(3), 'Position', [80*p startHeight-offset 60*p 30*p]);
set(h_calBoundsEdit(4), 'Position', [80*p startHeight-offset-20*p 60*p 30*p]);
set(h_calBoundsEdit(5), 'Position', [150*p startHeight-offset 60*p 30*p]);
set(h_calBoundsEdit(6), 'Position', [150*p startHeight-offset-20*p 60*p 30*p]);
set(h_calBoundsEdit(7), 'Position', [220*p startHeight-offset 60*p 30*p]);
set(h_calBoundsEdit(8), 'Position', [220*p startHeight-offset-20*p 60*p 30*p]);
set(h_calRadio(1), 'Position', [10*p startHeight-offset-55*p 50*p 30*p]);
set(h_calRadio(2), 'Position', [70*p startHeight-offset-55*p 50*p 30*p]);
set(h_calButton, 'Position', [10*p startHeight-170*p 70*p 40*p]);

% center dialog

movegui(db.Figure, 'center');

% maximize if we're on a small screen

set(0, 'units', 'pixels');
pix = get(0, 'screensize');
if pix(4) < GUIHeightRaw
    set(db.Figure, 'units', 'normalized')
    set(db.Figure, 'outerposition', [0 0 1 1]);
end

% fix missing button problem

feval(get(db.Figure,'SizeChangedFcn'));

%% callbacks and defaults

% defaults

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'type', 'crystal');
obj = changeObject(obj, 'crystal', 'orientationSystem', 'xyz'); % abc may not search entire space

set(db.Axes, 'FontSize', 16*f)
set(db.Axes.Title, 'Visible', 'off');
hold(db.Axes, 'on')
view(obj.detector.image, 'show', db.Axes);
axis(db.Axes, 'equal')

set(h_roiRadio(1), 'Value', 1);
set(h_roiEdit(2), 'String', num2str(obj.calibration.opts.roiNum, '%d'));
set(h_poiRadio(1), 'Value', 1);

set(h_calSizeEdit(2), 'String', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(h_calBoundsEdit(2), 'String', num2str(obj.calibration.searchBounds(1)));
set(h_calBoundsEdit(4), 'String', num2str(obj.calibration.searchBounds(2)));
set(h_calBoundsEdit(6), 'String', num2str(obj.calibration.searchBounds(3)));
set(h_calBoundsEdit(8), 'String', num2str(obj.calibration.searchBounds(4)));

if strcmp(obj.crystal.orientationSystem, 'xyz')
    set(h_calRadio(1), 'Value', 1);
else
    set(h_calRadio(2), 'Value', 1);
end

% callbacks

set(h_roiRadio, 'Callback', {@changeROIRadio, mainFigure, h_roiRadio, ...
    h_roiEdit, db.Axes})
set(h_roiEdit, 'Callback', {@changeROIEdit, mainFigure, h_roiEdit, ...
    db.Axes});
set(h_poiRadio, 'Callback', {@changePOIRadio, mainFigure, h_poiRadio, ...
    db.Axes})

set(h_calSizeEdit, 'Callback', {@changeCalSizeEdit, mainFigure, ...
    h_calSizeEdit});
set(h_calBoundsEdit, 'Callback', {@changeEdit, mainFigure, h_calBoundsEdit, ...
    nan, 'calibration', 'searchBounds'});
set(h_calRadio, 'Callback', {@changeCalRadio, mainFigure, h_calRadio, ...
    h_calBoundsEdit})
set(h_calButton, 'Callback', {@pressCalButton, mainFigure})

%% initial solve

pause(0.01); % let GUI settle before attempting auto ROI

if exist('islocalmax2', 'file') == 2
    obj = calROI(obj);
    obj = calCC(obj);
    obj = calPOI(obj);
    plot(db.Axes, obj.calibration.poi(:,1), obj.calibration.poi(:,2), ...
        '*', 'color', 'r', 'markersize', 5);
else
    set(h_roiRadio(1), 'enable', 'off');
    errordlg('Auto peak finding requires MATLAB 2024a or greater')
end
set(mainFigure, 'UserData', obj);

end

%% callback functions

function changeROIRadio(src, event, mainFigure, hRadio, hEdit, ax)
obj = get(mainFigure, 'UserData');
set(hRadio(1:2), 'Value', 0);
set(src, 'Value', 1);
if get(hRadio(1), 'Value')
    set(hEdit(2), 'Enable', 'on');
else
    set(hEdit(2), 'Enable', 'off');
end
obj = changeObject(obj, 'calibration', 'opts', 'roiSelect', get(src,'String'));
delete(findobj(ax,'Type','Line'))
obj = calROI(obj, ax);
if isempty(obj.calibration.roi) && get(hRadio(2), 'Value') % user doesn't pick anyting
    set(hRadio(1), 'Value', 1)
    set(hRadio(2), 'Value', 0);
    set(hEdit(2), 'Enable', 'on');
    set(hEdit(2), 'String', '3');
    obj = changeObject(obj, 'calibration', 'opts', 'roiNum', 3);
    if exist('islocalmax2', 'file') ~= 2
        return
    end
    obj = changeObject(obj, 'calibration', 'opts', 'roiSelect', 'auto');
        obj = calROI(obj);
end
obj = calCC(obj);
obj = calPOI(obj);
plot(ax, obj.calibration.poi(:,1), obj.calibration.poi(:,2), 'r*', ...
    'markersize', 5);
set(hEdit(2), 'String', num2str(obj.calibration.opts.roiNum, '%d'));
set(mainFigure, 'UserData', obj);
end

function changeROIEdit(src, event, mainFigure, h, ax)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'roiNum', editExtract(h));
set(h(2), 'String', num2str(obj.calibration.opts.roiNum, '%d'));
obj = calROI(obj, ax);
obj = calCC(obj);
obj = calPOI(obj);
delete(findobj(ax,'Type','Line'))
plot(ax, obj.calibration.poi(:,1), obj.calibration.poi(:,2), 'r*', ...
    'markersize', 5);
set(mainFigure, 'UserData', obj);
end

function changePOIRadio(src, event, mainFigure, hRadio, ax)
obj = get(mainFigure, 'UserData');
set(hRadio(1:3), 'Value', 0);
set(src, 'Value', 1);
obj = changeObject(obj, 'calibration', 'opts', 'poiType', get(src,'String'));
obj = calPOI(obj);
delete(findobj(ax,'Type','Line'))
plot(ax, obj.calibration.poi(:,1), obj.calibration.poi(:,2), 'r*', ...
    'markersize', 5);
set(mainFigure, 'UserData', obj);
end

function changeCalSizeEdit(src, event, mainFigure, h)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'gaPopulation', editExtract(h));
set(h(2), 'String', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(mainFigure, 'UserData', obj);
end

function changeCalRadio(src, event, mainFigure, hRadio, hEdit)
obj = get(mainFigure, 'UserData');
set(hRadio(1:2), 'Value', 0);
set(src, 'Value', 1);
str = get(src,'String');
set(hEdit(1), 'String', ['± R', str(1)]);
set(hEdit(3), 'String', ['± R', str(2)]);
set(hEdit(5), 'String', ['± R', str(3)]);
obj = changeObject(obj, 'crystal', 'orientationSystem', str);
set(mainFigure, 'UserData', obj);
end

function pressCalButton(src, event, mainFigure)
close(ancestor(src,'figure'));
obj = get(mainFigure, 'UserData');
obj = calSolve(obj);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end



