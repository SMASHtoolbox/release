function calDetectorManualDlg(src, event, mainFigure)

%% dialog box creation

% basics

[db, ex] = createDlg(mainFigure, 'calDetectorManualDlg', 'dialogplot');
if ex
    return
end

close(ancestor(src,'figure'));
db.Name = 'Detector Calibration';

% handles

h_roiLabel = addblock(db, 'text', 'ROI Selection');
h_roiEdit = addblock(db, 'edit', 'Threshold');
h_roiButtonBack = addblock(db, 'button', 'Background');
h_roiButtonSplit = addblock(db, 'button', 'Split');
h_roiButtonMask = addblock(db, 'button', 'Mask');

h_poiLabel = addblock(db, 'text', 'POI Selection');
h_poiEditSize = addblock(db, 'edit', 'Min Reg Size');
h_poiEditDist = addblock(db, 'edit', 'Min Pt Dist');
h_poiEditNum = addblock(db, 'edit', 'Max Pt Num');
h_poiEditCutoff = addblock(db, 'edit', 'Int Cutoff');
h_poiButton = addblock(db, 'button', 'Find');

h_calLabel = addblock(db, 'text', 'Calibration');
h_calEditSize = addblock(db, 'edit', 'Pop Size:');
h_calEditBounds = addblock(db, 'custom', ...
    {'edit','edit','edit', 'edit', 'edit', 'edit'}, ...
    {'± x', '± y', '± z','± Rx', '± Ry', '± Rz'});
h_calButton = addblock(db, 'button', 'Solve');

% initial sizing

dbPos = [0.1 0.1 0.5 0.4];
GUIHeightRaw = 800;
cpWidth = 325;
movegui(db.Figure, 'center');

% determine scaling

[p, f] = determineScaling(GUIHeightRaw, .85);
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
editFontSize = textFontSize;

set(h_roiLabel, 'FontSize', labelFontSize);
set(h_roiLabel, 'FontWeight', 'bold');
set(h_poiLabel, 'FontSize', labelFontSize);
set(h_poiLabel, 'FontWeight', 'bold');
set(h_calLabel, 'FontSize', labelFontSize);
set(h_calLabel, 'FontWeight', 'bold');

set(h_roiButtonBack, 'FontSize', textFontSize);
set(h_roiButtonSplit, 'FontSize', textFontSize);
set(h_roiButtonMask, 'FontSize', textFontSize);
set(h_poiButton, 'FontSize', textFontSize);
set(h_calButton, 'FontSize', textFontSize);

for ii = 1:12
    if ii < 3
        set(h_roiEdit(ii), 'FontSize', editFontSize);
        set(h_poiEditSize(ii), 'FontSize', editFontSize);
        set(h_poiEditDist(ii), 'FontSize', editFontSize);
        set(h_poiEditNum(ii), 'FontSize', editFontSize);
        set(h_poiEditCutoff(ii), 'FontSize', editFontSize);
        set(h_calEditSize(ii), 'FontSize', editFontSize);
    end
    set(h_calEditBounds(ii), 'FontSize', editFontSize);
end

% gui shape and size (important this happens after font sizes)

figurePos = get(db.Figure, 'Position');
startHeight = figurePos(4) - 100*p;

pos = db.ControlPanel.Position;
pos([2 4]) = figurePos([2 4]);
pos(2) = 0;
pos(3) = cpWidth;
db.ControlPanel.Position = pos;

pos = db.PlotPanel.Position;
widthChange = cpWidth - pos(1);
pos(1) = cpWidth;
pos(3) = pos(3) - widthChange;
db.PlotPanel.Position = pos;

% positions

set(h_roiLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_roiButtonBack, 'Position', [10*p startHeight-40*p 100*p 40*p]);
set(h_roiEdit(1), 'Position', [120*p startHeight-15*p 75*p 30*p])
set(h_roiEdit(2), 'Position', [120*p startHeight-35*p 75*p 30*p])
set(h_roiButtonSplit, 'Position', [10*p startHeight-90*p 88*p 40*p]);
set(h_roiButtonMask, 'Position', [108*p startHeight-90*p 88*p 40*p]);

startHeight = startHeight - 170*p;
set(h_poiLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_poiEditSize(1), 'Position', [10*p startHeight-17*p 100*p 30*p])
set(h_poiEditSize(2), 'Position', [10*p startHeight-37*p 100*p 30*p])
set(h_poiEditDist(1), 'Position', [120*p startHeight-17*p 100*p 30*p])
set(h_poiEditDist(2), 'Position', [120*p startHeight-37*p 100*p 30*p])
set(h_poiEditNum(1), 'Position', [10*p startHeight-80*p 100*p 30*p])
set(h_poiEditNum(2), 'Position', [10*p startHeight-100*p 100*p 30*p])
set(h_poiEditCutoff(1), 'Position', [120*p startHeight-80*p 100*p 30*p])
set(h_poiEditCutoff(2), 'Position', [120*p startHeight-100*p 100*p 30*p])
set(h_poiButton, 'Position', [10*p startHeight-150*p 88*p 40*p]);

startHeight = startHeight - 230*p;
set(h_calLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_calEditSize(1), 'Position', [10*p startHeight-30*p 75*p 30*p])
set(h_calEditSize(2), 'Position', [85*p startHeight-20*p 60*p 30*p])
offset = 70*p;
set(h_calEditBounds(1), 'Position', [10*p startHeight-offset 60*p 30*p]);
set(h_calEditBounds(2), 'Position', [10*p startHeight-offset-20*p 60*p 30*p]);
set(h_calEditBounds(3), 'Position', [80*p startHeight-offset 60*p 30*p]);
set(h_calEditBounds(4), 'Position', [80*p startHeight-offset-20*p 60*p 30*p]);
set(h_calEditBounds(5), 'Position', [150*p startHeight-offset 60*p 30*p]);
set(h_calEditBounds(6), 'Position', [150*p startHeight-offset-20*p 60*p 30*p]);
offset = 130*p;
set(h_calEditBounds(7), 'Position', [10*p startHeight-offset 60*p 30*p]);
set(h_calEditBounds(8), 'Position', [10*p startHeight-offset-20*p 60*p 30*p]);
set(h_calEditBounds(9), 'Position', [80*p startHeight-offset 60*p 30*p]);
set(h_calEditBounds(10), 'Position', [80*p startHeight-offset-20*p 60*p 30*p]);
set(h_calEditBounds(11), 'Position', [150*p startHeight-offset 60*p 30*p]);
set(h_calEditBounds(12), 'Position', [150*p startHeight-offset-20*p 60*p 30*p]);
set(h_calButton, 'Position', [10*p startHeight-205*p 70*p 40*p]);

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
obj = changeObject(obj, 'calibration', 'type', 'detectorManual');

set(db.Axes, 'FontSize', 16*f)
set(db.Axes.Title, 'Visible', 'off');
hold(db.Axes, 'on')
view(obj.detector.image, 'show', db.Axes);
axis(db.Axes, 'equal')

set(h_calEditSize(2), 'String', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(h_calEditBounds(2), 'String', num2str(obj.calibration.searchBounds(1)));
set(h_calEditBounds(4), 'String', num2str(obj.calibration.searchBounds(2)));
set(h_calEditBounds(6), 'String', num2str(obj.calibration.searchBounds(3)));
set(h_calEditBounds(8), 'String', num2str(obj.calibration.searchBounds(4)));
set(h_calEditBounds(10), 'String', num2str(obj.calibration.searchBounds(5)));
set(h_calEditBounds(12), 'String', num2str(obj.calibration.searchBounds(6)));

% callbacks

set(h_roiEdit, 'Callback', {@changeOptEdit, mainFigure, h_roiEdit, ...
    'threshold'});
set(h_roiButtonBack, 'Callback', {@pressBackButton, mainFigure, db.Axes})
set(h_roiButtonSplit, 'Callback', {@pressSplitButton, mainFigure, db.Axes})
set(h_roiButtonMask, 'Callback', {@pressMaskButton, mainFigure, db.Axes})

set(h_poiEditSize, 'Callback', {@changeOptEdit, mainFigure, h_poiEditSize, ...
    'minRegSize'});
set(h_poiEditDist, 'Callback', {@changeOptEdit, mainFigure, h_poiEditDist, ...
    'minPointDist'});
set(h_poiEditNum, 'Callback', {@changeOptEdit, mainFigure, h_poiEditNum, ...
    'maxPointNum'});
set(h_poiEditCutoff, 'Callback', {@changeOptEdit, mainFigure, h_poiEditCutoff, ...
    'intCutoff'});
set(h_poiButton, 'Callback', {@pressFindButton, mainFigure, db.Axes})

set(h_calEditSize, 'Callback', {@changeCalEditSize, mainFigure, ...
    h_calEditSize});
set(h_calEditBounds, 'Callback', {@changeEdit, mainFigure, h_calEditBounds, ...
    nan, 'calibration', 'searchBounds'});
set(h_calButton, 'Callback', {@pressCalButton, mainFigure})

%% initial solve

pause(0.01); % let GUI settle before attempting auto threshold
obj = calThresh(obj);
set(h_roiEdit(2), 'String', num2str(obj.calibration.opts.threshold));
set(h_poiEditSize(2), 'String', num2str(obj.calibration.opts.minRegSize));
set(h_poiEditDist(2), 'String', num2str(obj.calibration.opts.minPointDist));
set(h_poiEditNum(2), 'String', num2str(obj.calibration.opts.maxPointNum));
set(h_poiEditCutoff(2), 'String', num2str(obj.calibration.opts.intCutoff));
set(mainFigure, 'UserData', obj);

end

%% callback functions

function changeOptEdit(src, event, mainFigure, h, opt)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', opt, editExtract(h));
set(h(2), 'String', num2str(obj.calibration.opts.(opt)));
set(mainFigure, 'UserData', obj);
end

function pressBackButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calProcessImage(obj, 'background');
view(obj.calibration.processedImage, 'show', ax);
set(mainFigure, 'UserData', obj);
end

function pressSplitButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calProcessImage(obj, 'mask', ax, {'connected', 'y', 2});
view(obj.calibration.processedImage, 'show', ax);
set(mainFigure, 'UserData', obj);
end

function pressMaskButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calProcessImage(obj, 'mask', ax);
view(obj.calibration.processedImage, 'show', ax);
set(mainFigure, 'UserData', obj);
end

function pressFindButton(source, event, mainFigure, ax)
obj = get(mainFigure, 'UserData');
obj = calCC(obj);
obj = calPOI(obj);
delete(findobj(ax,'Type','Line'))
for ii = 1:size(obj.calibration.poi,3)
    plot(ax, obj.calibration.poi(:,1,ii), obj.calibration.poi(:,2,ii), ...
        'r*', 'markersize', 5);
end
set(mainFigure, 'UserData', obj);
end

function changeCalEditSize(src, event, mainFigure, h)
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'calibration', 'opts', 'gaPopulation', editExtract(h));
set(h(2), 'String', num2str(obj.calibration.opts.gaOpts.PopulationSize, '%.0g'));
set(mainFigure, 'UserData', obj);
end

function pressCalButton(src, event, mainFigure)
close(ancestor(src,'figure'));
obj = get(mainFigure, 'UserData');
obj = calSolve(obj);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end



