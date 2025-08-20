function processDlg(src, event, mainFigure)

%% dialog box creation

% basics

[db, ex] = createDlg(mainFigure, 'processDlg', 'dialogplot');
if ex
    return
end

db.Name = 'Detector Image Processing';

% handles

h_ROILabel = addblock(db, 'text', 'ROI Selections');
h_crop = addblock(db, 'button', 'Crop');
h_cropReset = addblock(db, 'button', 'Reset');
h_back = addblock(db, 'button', 'Background');
h_backReset = addblock(db, 'button', 'Reset');
h_mask = addblock(db, 'button', 'Mask');
h_maskReset = addblock(db, 'button', 'Reset'); 
h_reverseMask = addblock(db, 'button', 'Reverse Mask');
h_reverseMaskReset = addblock(db, 'button', 'Reset'); 
h_scale = addblock(db, 'button', 'Scale');
h_scaleReset = addblock(db, 'button', 'Reset');
h_circle = addblock(db, 'check', ' Use Circle?'); 
h_ellipse = addblock(db, 'check', ' Use Ellipse?'); 
h_limLabel = addblock(db, 'text', 'Contour Limits');
h_limEdit = addblock(db, 'custom', {'edit', 'edit'}, ...
    {'Min', 'Max'});
h_limReset = addblock(db, 'button', 'Reset');
h_ccLabel = addblock(db, 'text', 'Conn Comp Filter');
h_ccList = addblock(db, 'listbox', 'Conn', ...
    {'4', '8'});
h_ccEdit = addblock(db, 'edit', 'Size');
h_ccButton = addblock(db, 'button', 'Filter');
h_ccReset = addblock(db, 'button', 'Reset');
h_smoothLabel = addblock(db, 'text', 'Smooth');
h_smoothList = addblock(db, 'listbox', 'Type', ...
    {'Mean', 'Median'});
h_smoothEdit = addblock(db, 'edit', 'Value');
h_smoothButton = addblock(db, 'button', 'Filter');
h_smoothReset = addblock(db, 'button', 'Reset');
h_bandFilterLabel = addblock(db, 'text', 'Bandpass');
h_bandFilterList = addblock(db, 'listbox', 'Type', ...
    {'Ideal', 'Gaussian', 'Butterworth', 'Chebyshev'});
h_bandFilterEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'Min', 'Max', 'Order'});
h_bandFilterButton = addblock(db, 'button', 'Filter');
h_bandFilterReset = addblock(db, 'button', 'Reset');
h_saveLabel = addblock(db, 'text', 'Save');
h_save = addblock(db, 'button', 'Save');
h_revert = addblock(db, 'button', 'Revert');
h_reset = addblock(db, 'button', 'Reset');

% initial sizing

dbPos = [0.1 0.1 0.8 0.8];
GUIHeight = 1000;

% determine scaling

[p, f] = determineScaling(GUIHeight, dbPos(end));
set(db.Figure, 'Units', 'normalized');
set(db.Figure, 'Position', dbPos);
set(db.Figure, 'Units', 'pixels');
GUIHeight = GUIHeight*p;

posC = get(db.ControlPanel, 'position');
posC(4) = GUIHeight;
set(db.ControlPanel, 'position', posC);
posP = get(db.PlotPanel, 'position');
posP(4) = GUIHeight;
set(db.PlotPanel, 'position', posP);
posF = get(db.Figure, 'position');
posF(4) = GUIHeight;
set(db.Figure, 'position', posF);

%% re-positioning

% font sizes

labelFontSize = 12*f;
labelFontWeight = 'bold';
fontSize = 10*f;

set(h_ROILabel, 'FontSize', labelFontSize);
set(h_ROILabel, 'FontWeight', labelFontWeight);
set(h_crop, 'FontSize', fontSize);
set(h_cropReset, 'FontSize', fontSize);
set(h_back, 'FontSize', fontSize);
set(h_backReset, 'FontSize', fontSize);
set(h_mask, 'FontSize', fontSize);
set(h_maskReset, 'FontSize', fontSize);
set(h_reverseMask, 'FontSize', fontSize);
set(h_reverseMaskReset, 'FontSize', fontSize);
set(h_scale, 'FontSize', fontSize);
set(h_scaleReset, 'FontSize', fontSize);
set(h_circle, 'FontSize', fontSize);
set(h_ellipse, 'FontSize', fontSize);
set(h_limLabel, 'FontSize', labelFontSize);
set(h_limLabel, 'FontWeight', labelFontWeight);
set(h_limEdit, 'FontSize', fontSize);
set(h_limReset, 'FontSize', fontSize);
set(h_ccLabel, 'FontSize', labelFontSize);
set(h_ccLabel, 'FontWeight', labelFontWeight);
set(h_ccList, 'FontSize', fontSize);
set(h_ccEdit, 'FontSize', fontSize);
set(h_ccButton, 'FontSize', fontSize);
set(h_ccReset, 'FontSize', fontSize);
set(h_smoothLabel, 'FontSize', labelFontSize);
set(h_smoothLabel, 'FontWeight', labelFontWeight);
set(h_smoothList, 'FontSize', fontSize);
set(h_smoothEdit, 'FontSize', fontSize);
set(h_smoothButton, 'FontSize', fontSize);
set(h_smoothReset, 'FontSize', fontSize);
set(h_bandFilterLabel, 'FontSize', labelFontSize);
set(h_bandFilterLabel, 'FontWeight', labelFontWeight);
set(h_bandFilterList, 'FontSize', fontSize);
set(h_bandFilterEdit, 'FontSize', fontSize);
set(h_bandFilterButton, 'FontSize', fontSize);
set(h_bandFilterReset, 'FontSize', fontSize);
set(h_saveLabel, 'FontSize', labelFontSize);
set(h_saveLabel, 'FontWeight', labelFontWeight);
set(h_save, 'FontSize', fontSize);
set(h_revert, 'FontSize', fontSize);
set(h_reset, 'FontSize', fontSize);

% shape and size

figurePos = get(db.Figure, 'Position');
startHeight = figurePos(4) - 40*p;

cpWidth = 350*p;
pos = db.ControlPanel.Position;
pos(2:2:4) = figurePos(2:2:4);
pos(2) = pos(2) + 200*p;
pos(3) = cpWidth;
db.ControlPanel.Position = pos;

pos = db.PlotPanel.Position;
widthChange = cpWidth - pos(1);
pos(1) = cpWidth;
pos(3) = pos(3) - widthChange;
db.PlotPanel.Position = pos;

catSep = 60*p;

labelOffset = 30*p;
offset = 40*p;
set(h_ROILabel, 'Position', [10*p startHeight 200*p 30*p])
set(h_crop, 'Position', [10*p startHeight-labelOffset 100*p 30*p])
set(h_cropReset, 'Position', [120*p startHeight-labelOffset 100*p 30*p])
set(h_back, 'Position', [10*p startHeight-labelOffset-offset 100*p 30*p])
set(h_backReset, 'Position', [120*p startHeight-labelOffset-offset 100*p 30*p])
set(h_mask, 'Position', [10*p startHeight-labelOffset-2*offset 100*p 30*p])
set(h_maskReset, 'Position', [120*p startHeight-labelOffset-2*offset 100*p 30*p]);
set(h_reverseMask, 'Position', [10*p startHeight-labelOffset-3*offset 100*p 30*p])
set(h_reverseMaskReset, 'Position', [120*p startHeight-labelOffset-3*offset 100*p 30*p]);
set(h_scale, 'Position', [10*p startHeight-labelOffset-4*offset 100*p 30*p])
set(h_scaleReset, 'Position', [120*p startHeight-labelOffset-4*offset 100*p 30*p]);
set(h_circle, 'Position', [10*p startHeight-labelOffset-4.75*offset 200*p 30*p]);
set(h_ellipse, 'Position', [120*p startHeight-labelOffset-4.75*offset 200*p 30*p]);

startHeight = startHeight - labelOffset-4.3*offset-catSep;
offset = 20*p;
width = 60*p;
set(h_limLabel, 'Position', [10*p startHeight 200*p 30*p]);
set(h_limEdit(1), 'Position', [10*p startHeight-labelOffset width 30*p]);
set(h_limEdit(3), 'Position', [20*p+width startHeight-labelOffset width 30*p]);
set(h_limEdit(2), 'Position', [10*p startHeight-labelOffset-offset width 30*p]);
set(h_limEdit(4), 'Position', [20*p+width startHeight-labelOffset-offset width 30*p]);
set(h_limReset, 'Position', [40*p+2*width startHeight-labelOffset-offset 80*p 30*p])

startHeight = startHeight-labelOffset-offset-catSep;
set(h_ccLabel, 'Position', [10*p startHeight 200*p 30*p])
set(h_ccList(1), 'Position', [10*p startHeight-labelOffset 100*p 30*p])
set(h_ccList(2), 'Position', [10*p startHeight-labelOffset-25*p 100*p 35*p])
set(h_ccEdit(1), 'Position', [130*p startHeight-labelOffset width 30*p])
set(h_ccEdit(2), 'Position', [130*p startHeight-labelOffset-20*p width 30*p])
set(h_ccButton, 'Position', [10*p startHeight-labelOffset-35*p-30*p 80*p 30*p])
set(h_ccReset, 'Position', [100*p startHeight-labelOffset-35*p-30*p 80*p 30*p])

startHeight = startHeight-labelOffset-35*p-25*p-catSep;
set(h_smoothLabel, 'Position', [10*p startHeight 200*p 30*p])
set(h_smoothList(1), 'Position', [10*p startHeight-labelOffset 100*p 30*p])
set(h_smoothList(2), 'Position', [10*p startHeight-labelOffset-25*p 100*p 35*p])
set(h_smoothEdit(1), 'Position', [130*p startHeight-labelOffset width 30*p])
set(h_smoothEdit(2), 'Position', [130*p startHeight-labelOffset-20*p width 30*p])
set(h_smoothButton, 'Position', [10*p startHeight-labelOffset-35*p-30*p 80*p 30*p])
set(h_smoothReset, 'Position', [100*p startHeight-labelOffset-35*p-30*p 80*p 30*p])

startHeight = startHeight-labelOffset-35*p-25*p-catSep; 
set(h_bandFilterLabel, 'Position', [10*p startHeight 200*p 30*p])
set(h_bandFilterList(1), 'Position', [10*p startHeight-labelOffset 100*p 30*p])
set(h_bandFilterList(2), 'Position', [10*p startHeight-2.5*labelOffset-20*p 100*p 75*p])
set(h_bandFilterEdit(1), 'Position', [130*p startHeight-labelOffset width 30*p])
set(h_bandFilterEdit(2), 'Position', [130*p startHeight-labelOffset-20*p width 30*p])
set(h_bandFilterEdit(3), 'Position', [150*p+width startHeight-labelOffset width 30*p])
set(h_bandFilterEdit(4), 'Position', [150*p+width startHeight-labelOffset-20*p width 30*p])
set(h_bandFilterEdit(5), 'Position', [170*p+2*width startHeight-labelOffset width 30*p])
set(h_bandFilterEdit(6), 'Position', [170*p+2*width startHeight-labelOffset-20*p width 30*p])
set(h_bandFilterButton, 'Position', [10*p startHeight-2.5*labelOffset-15*p-50*p 80*p 30*p])
set(h_bandFilterReset, 'Position', [100*p startHeight-2.5*labelOffset-15*p-50*p 80*p 30*p])

startHeight = startHeight-2.5*labelOffset-15*p-40*p-catSep;
set(h_saveLabel, 'Position', [10*p startHeight 200*p 30*p])
set(h_save, 'Position', [10*p startHeight-labelOffset 80*p 30*p])
set(h_revert, 'Position', [100*p startHeight-labelOffset 80*p 30*p])
set(h_reset, 'Position', [190*p startHeight-labelOffset 80*p 30*p])

% center dialog

movegui(db.Figure, 'center');

% fix missing button problem

feval(get(db.Figure,'SizeChangedFcn'));

%% callbacks and defaults

% defaults

set(db.Axes, 'FontSize', 16*f)
set(db.Axes.Title, 'Visible', 'off');
hold(db.Axes, 'on')

set(h_limEdit(2), 'Tag', 'clim1');
set(h_limEdit(4), 'Tag', 'clim2');

set(h_ccEdit(2), 'String', num2str(20));
set(h_smoothEdit(2), 'String', num2str(1));
set(h_bandFilterEdit(2), 'String', num2str(0));
set(h_bandFilterEdit(4), 'String', num2str(1));
set(h_bandFilterEdit(6), 'String', num2str(1));

% callbacks

set(h_crop, 'Callback', {@processCrop, mainFigure});
set(h_cropReset, 'Callback', {@processCropReset, mainFigure});
set(h_back, 'Callback', {@processBack, mainFigure, h_circle, h_ellipse});
set(h_backReset, 'Callback', {@processBackReset, mainFigure});
set(h_mask, 'Callback', {@processMask, mainFigure, h_circle, h_ellipse});
set(h_maskReset, 'Callback', {@processMaskReset, mainFigure});
set(h_reverseMask, 'Callback', {@processReverseMask, mainFigure, h_circle, h_ellipse});
set(h_reverseMaskReset, 'Callback', {@processReverseMaskReset, mainFigure});
set(h_scale, 'Callback', {@processScale, mainFigure, h_circle, h_ellipse});
set(h_scaleReset, 'Callback', {@processScaleReset, mainFigure});
set(h_circle, 'Callback', {@processCircle, h_circle, h_ellipse});
set(h_ellipse, 'Callback', {@processCircle, h_circle, h_ellipse});
set(h_limEdit, 'Callback', {@processLimEdit, mainFigure, h_limEdit});
set(h_limReset, 'Callback', {@processLimReset, mainFigure, h_limEdit});
set(h_ccButton, 'Callback', {@processCC, mainFigure, h_ccList, h_ccEdit});
set(h_ccReset, 'Callback', {@processCCReset, mainFigure});
set(h_smoothButton, 'Callback', {@processSmooth, mainFigure, ...
    h_smoothList, h_smoothEdit});
set(h_smoothReset, 'Callback', {@processSmoothReset, mainFigure});
set(h_bandFilterButton, 'Callback', {@processFilter, mainFigure, ...
    h_bandFilterList, h_bandFilterEdit});
set(h_bandFilterReset, 'Callback', {@processFilterReset, mainFigure});
set(h_save, 'Callback', {@processSave, mainFigure});
set(h_revert, 'Callback', {@processRevert, mainFigure});
set(h_reset, 'Callback', {@processReset, mainFigure});

% re-save to app data so you have Tags

setappdata(mainFigure, 'processDlg', db)

% check for image and then plot

obj = get(mainFigure, 'UserData');
if isnumeric(obj.detector.image)
    importDetectorImage(mainFigure);
    obj = get(mainFigure, 'UserData');
    if isnumeric(obj.detector.image)
        close(db.Figure)
    end
end
updatePlotPredictionAnalysis(mainFigure, 'imageProcessingDisplay');

% check if we can use the circle ROI

pause(0.01);
v = version('-release');
yr = str2double(v(1:4));
if yr > 2018 || (yr == 2018 && strcmp(v(end), 'b'))
    if license('test', 'image_toolbox')
        set(h_circle, 'Value', true)
    end
end

end

function processCrop(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
obj = processImage(obj, 'crop', ax);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
xlim(ax, [min(obj.detector.image.Grid1) max(obj.detector.image.Grid1)]);
ylim(ax, [min(obj.detector.image.Grid2) max(obj.detector.image.Grid2)]);
end

function processCropReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'cropReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
xlim(ax, [min(obj.detector.image.Grid1) max(obj.detector.image.Grid1)]);
ylim(ax, [min(obj.detector.image.Grid2) max(obj.detector.image.Grid2)]);
end

function processBack(src, event, mainFigure, h_circle, h_ellipse)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    ind = drawCircle(ax);
    obj = processImage(obj, 'background', ind);
elseif get(h_ellipse, 'Value')
    ind = drawCircle(ax, 'ellipse');
    obj = processImage(obj, 'background', ind);
else
    obj = processImage(obj, 'background', ax);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processBackReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'backgroundReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processMask(src, event, mainFigure, h_circle, h_ellipse)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    ind = drawCircle(ax);
    obj = processImage(obj, 'mask', ind);
elseif get(h_ellipse, 'Value')
    ind = drawCircle(ax, 'ellipse');
    obj = processImage(obj, 'mask', ind);
else
    obj = processImage(obj, 'mask', ax);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processMaskReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'maskReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processReverseMask(src, event, mainFigure, h_circle, h_ellipse)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    ind = drawCircle(ax);
    obj = processImage(obj, 'mask', ind, true);
elseif get(h_ellipse, 'Value')
    ind = drawCircle(ax, 'ellipse');
    obj = processImage(obj, 'mask', ind);
else
    obj = processImage(obj, 'mask', ax, true);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processReverseMaskReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'reverseMaskReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processScale(src, event, mainFigure, h_circle)
obj = get(mainFigure, 'UserData');
ax = get(ancestor(src, 'figure'), 'CurrentAxes');
if get(h_circle, 'Value')
    [~, diam] = drawCircle(ax);
    obj = processImage(obj, 'scale', diam);
else
    obj = processImage(obj, 'scale', ax);
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processScaleReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'scaleReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processCircle(src, event, h_circle, h_ellipse)

% handle set logic

if contains(get(src,'String'), 'Circle')
    set(h_ellipse, 'Value', 0);
else
    set(h_circle, 'Value', 0);
end

% check that we can set desired

v = version('-release');
yr = str2double(v(1:4));
okFlag = false;
if yr > 2018 || (yr == 2018 && strcmp(v(end), 'b'))
    if license('test', 'image_toolbox')
        okFlag = true;
    end
end
if ~okFlag && get(src, 'Value')
    set(src, 'Value', false);
    errordlg(['Must have 2018b or later Image Processing Toolbox to ' ...
        'use circle ROIs']);
end
end

function processLimEdit(src, event, mainFigure, h_limEdit)
newVal = editExtract(h_limEdit);
obj = get(mainFigure, 'UserData');
if any(isnan(newVal))
    newVal = obj.detector.image.DataLim;
    if ischar(newVal)
        newVal = [min(min(obj.detector.image.Data)), ...
            max(max(obj.detector.image.Data))];
    end
end
obj = processImage(obj, 'contourLimits', newVal);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'imageProcessingDisplay');
end

function processLimReset(src, event, mainFigure, h_limEdit)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'contourLimitsReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'imageProcessingDisplay');
end

function processCC(src, event, mainFigure, h_ccList, h_ccEdit)
listOptions = get(h_ccList(2), 'String');
conn = str2double(listOptions{get(h_ccList(2), 'Value')});
P = editExtract(h_ccEdit);
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'ccFilter', P, conn);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processCCReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'ccFilterReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processSmooth(src, event, mainFigure, h_smoothList, h_smoothEdit)
listOptions = get(h_smoothList(2), 'String');
smoothType = listOptions{get(h_smoothList(2), 'Value')};
smoothValue = editExtract(h_smoothEdit);
if ~isnan(smoothValue)
    obj = get(mainFigure, 'UserData');
    obj = processImage(obj, 'smooth', smoothType, smoothValue);
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
else
    errordlg('Bad smoothing inputs', 'Bad smoothing inputs')
end
end

function processSmoothReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'smoothReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processFilter(src, event, mainFigure, h_filterList, h_filterEdit)
listOptions = get(h_filterList(2), 'String');
filterType = listOptions{get(h_filterList(2), 'Value')};
filterRange = editExtract(h_filterEdit);
if ~any(isnan(filterRange(1:2)))
    if isnan(filterRange(3))
        filterRange(3) = 1;
    end
    obj = get(mainFigure, 'UserData');
    obj = processImage(obj, 'bandpassfilter', filterRange(1:2), filterType, ...
        filterRange(3));
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
else
    errordlg('Bad filter inputs', 'Bad filter inputs')
end
end

function processFilterReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'filterReset');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processSave(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'save');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processRevert(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'revertToSave');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end

function processReset(src, event, mainFigure)
obj = get(mainFigure, 'UserData');
obj = processImage(obj, 'revertToOriginal');
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);
end
