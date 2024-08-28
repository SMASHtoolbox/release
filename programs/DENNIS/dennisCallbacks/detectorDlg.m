function detectorDlg(src, event)

%% dialog box creation

mainFigure = ancestor(src, 'figure', 'toplevel');
[db, ex] = createDlg(mainFigure, 'detectorDlg', 'dialog');
if ex
    return
end

db.Name = 'X-ray Detector Parameters';

% shape and size

h_shapeLabel = addblock(db, 'text', 'Shape');
h_shapeRadio = addblock(db, 'radio', {'Rectangle', 'Circle'});
h_shapeEdit = addblock(db, 'custom', {'edit', 'edit'}, ...
    {'Height', 'Width'});
h_shapeText = addblock(db, 'text', 'mm');
h_shapeSlider = addblock(db, 'slider', 'Transparency');
h_shapeButton = addblock(db, 'custom', {'button', 'button', 'button'}, ...
    {'Load', 'Process', 'Unload'});

% position

h_posLabel = addblock(db, 'text', 'Position (mm)');
h_posSlider = addblock(db, 'slider', ' ');
h_posSliderRadio = addblock(db, 'radio', {'x', 'y', 'z'});
h_posEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});

% orientation

h_orLabel = addblock(db, 'text', 'Orientation (deg)');
h_orSlider = addblock(db, 'slider', ' ');
h_orSliderRadio = addblock(db, 'radio', {'x', 'y', 'z'});
h_orEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});
h_orButton = addblock(db, 'button', 'Reset');

% determine scaling

GUIHeight = 640;
[p, f] = determineScaling(GUIHeight,.85);

% re-size whole GUI

pos = get(db.Handle, 'Position');
pos(3) = 450*p;
pos(4) = GUIHeight*p;
set(db.Handle, 'Position', pos);

%% re-positioning

% delete unused label handles

delete(h_posSlider(1));
delete(h_orSlider(1));

% change batch fonts

for ii = 1:length(h_posEdit)
    set(h_posEdit(ii), 'FontSize', 12*f);
    set(h_orEdit(ii), 'FontSize', 12*f);
    if ii < 5
        set(h_shapeEdit(ii), 'FontSize', 12*f);
    end
end

% shape and size

startHeight = pos(4) - 60*p;
offset = 10*p;
offset2 = offset + 40*p;
offset3 = offset2 + 60*p;
offset4 = offset3 + 85*p;

set(h_shapeLabel, 'FontSize', 18*f);
set(h_shapeLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_shapeRadio(1), 'FontSize', 12*f);
set(h_shapeRadio(2), 'FontSize', 12*f);
set(h_shapeRadio(1), 'Position', [10*p startHeight-offset 100*p 20*p]);
set(h_shapeRadio(2), 'Position', [110*p startHeight-offset 100*p 20*p]);

set(h_shapeEdit(1), 'Position', [10*p startHeight-offset2 70*p 30*p]);
set(h_shapeEdit(2), 'Position', [10*p startHeight-offset2-20*p 70*p 30*p]);
set(h_shapeEdit(3), 'Position', [90*p startHeight-offset2 70*p 30*p]);
set(h_shapeEdit(4), 'Position', [90*p startHeight-offset2-20*p 70*p 30*p]);

set(h_shapeText, 'FontSize', 10*f);
set(h_shapeText, 'Position', [170*p startHeight-offset2-30*p 70*p 30*p]);

set(h_shapeSlider(1), 'FontSize', 12*f);
set(h_shapeSlider(3), 'FontSize', 12*f);
set(h_shapeSlider(1), 'Position', [10*p startHeight-offset3, 200*p 30*p]);
set(h_shapeSlider(2), 'Position', [10*p startHeight-offset3-30*p 200*p 30*p]);
set(h_shapeSlider(3), 'Position', [220*p startHeight-offset3-30*p 55*p 30*p]);

set(h_shapeButton(1), 'FontSize', 12*f);
set(h_shapeButton(2), 'FontSize', 12*f);
set(h_shapeButton(3), 'FontSize', 12*f);
set(h_shapeButton(1), 'Position', [10*p startHeight-offset4 80*p 40*p]);
set(h_shapeButton(2), 'Position', [100*p startHeight-offset4 80*p 40*p]);
set(h_shapeButton(3), 'Position', [190*p startHeight-offset4 80*p 40*p]);

% position

startHeight2 = startHeight - offset4 - 80*p;

set(h_posLabel, 'FontSize', 18*f);
set(h_posLabel, 'Position', [10*p startHeight2 200*p 50*p]);
set(h_posSlider(2), 'Position', [10*p startHeight2-20*p 200*p 30*p]);
set(h_posSlider(3), 'FontSize', 12);
set(h_posSlider(3), 'Position', [220*p startHeight2-20*p 55*p 30*p]);
set(h_posSliderRadio(1), 'FontSize', 12*f);
set(h_posSliderRadio(2), 'FontSize', 12*f);
set(h_posSliderRadio(3), 'FontSize', 12*f);
set(h_posSliderRadio(1), 'Position', [290*p startHeight2-15*p 36*p 20*p]);
set(h_posSliderRadio(2), 'Position', [332*p startHeight2-15*p 36*p 20*p]);
set(h_posSliderRadio(3), 'Position', [374*p startHeight2-15*p 36*p 20*p]);

offset = 60*p;
set(h_posEdit(1), 'Position', [10*p startHeight2-offset 60*p 30*p]);
set(h_posEdit(2), 'Position', [10*p startHeight2-offset-20*p 60*p 30*p]);
set(h_posEdit(3), 'Position', [80*p startHeight2-offset 60*p 30*p]);
set(h_posEdit(4), 'Position', [80*p startHeight2-offset-20*p 60*p 30*p]);
set(h_posEdit(5), 'Position', [150*p startHeight2-offset 60*p 30*p]);
set(h_posEdit(6), 'Position', [150*p startHeight2-offset-20*p 60*p 30*p]);

% orientation

startHeight3 = startHeight2 - offset - 20*p - 80*p;

set(h_orLabel, 'FontSize', 18*f);
set(h_orLabel, 'Position', [10*p startHeight3 200*p 50*p]);
set(h_orSlider(2), 'Position', [10*p startHeight3-20*p 200*p 30*p]);
set(h_orSlider(3), 'FontSize', 12*f);
set(h_orSlider(3), 'Position', [220*p startHeight3-20*p 55*p 30*p]);
set(h_orSliderRadio(1), 'FontSize', 12*f);
set(h_orSliderRadio(2), 'FontSize', 12*f);
set(h_orSliderRadio(3), 'FontSize', 12*f);
set(h_orSliderRadio(1), 'Position', [290*p startHeight3-15*p 36*p 20*p]);
set(h_orSliderRadio(2), 'Position', [332*p startHeight3-15*p 36*p 20*p]);
set(h_orSliderRadio(3), 'Position', [374*p startHeight3-15*p 36*p 20*p]);

offset = 60*p;
set(h_orEdit(1), 'Position', [10*p startHeight3-offset 60*p 30*p]);
set(h_orEdit(2), 'Position', [10*p startHeight3-offset-20*p 60*p 30*p]);
set(h_orEdit(3), 'Position', [80*p startHeight3-offset 60*p 30*p]);
set(h_orEdit(4), 'Position', [80*p startHeight3-offset-20*p 60*p 30*p]);
set(h_orEdit(5), 'Position', [150*p startHeight3-offset 60*p 30*p]);
set(h_orEdit(6), 'Position', [150*p startHeight3-offset-20*p 60*p 30*p]);

set(h_orButton, 'FontSize', 12*f);
set(h_orButton, 'Position', [10*p startHeight3-offset-20*p-50*p 80*p 40*p]);

% re-position whole GUI

positionDlg(db, mainFigure);

%% callbacks and defaults

% defaults

obj = get(mainFigure, 'UserData');
obj = obj.detector;

set(h_shapeRadio(1), 'Tag', 'shape1')
set(h_shapeRadio(2), 'Tag', 'shape2')
set(h_shapeEdit(2), 'Tag', 'size1')
set(h_shapeEdit(4), 'Tag', 'size2');
set(h_shapeEdit(1), 'Tag', 'label1');
set(h_shapeEdit(3), 'Tag', 'label2');

switch obj.shape
    case 'rectangle'
        set(h_shapeRadio(1), 'Value', 1);
        set(h_shapeRadio(2), 'Value', 0);
        set(h_shapeEdit(4), 'String', obj.size(2));
    case 'circle'
        set(h_shapeRadio(1), 'Value', 0);
        set(h_shapeRadio(2), 'Value', 1);
        set(h_shapeEdit(1), 'String', 'Diameter');
        set(h_shapeEdit(3), 'String', '');
        set(h_shapeEdit(4), 'enable', 'off');
        set(h_shapeEdit(4), 'String', '');
    otherwise
        error('Unexpected Shape');
end

set(h_shapeEdit(2), 'String', num2str(obj.size(1)));

set(h_shapeSlider(2), 'Value', obj.faceAlpha);
set(h_shapeSlider(3), 'String', num2str(obj.faceAlpha));
set(h_shapeSlider(2), 'Max', 1);
set(h_shapeSlider(2), 'Min', 0);
set(h_shapeSlider(2), 'Tag', 'alphaSlide')
set(h_shapeSlider(3), 'Tag', 'alphaEdit')

set(h_posSlider(2), 'Value', 0);
set(h_posSlider(3), 'String', '0');
set(h_posSlider(3), 'Enable', 'off');
set(h_posSlider(2), 'Max', 1);
set(h_posSlider(2), 'Min', -1);
set(h_posSliderRadio(1), 'Value', 1);
set(h_posEdit(2), 'String', num2str(obj.location(1)));
set(h_posEdit(4), 'String', num2str(obj.location(2)));
set(h_posEdit(6), 'String', num2str(obj.location(3)));

set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'String', '0');
set(h_orSlider(3), 'Enable', 'off');
set(h_orSlider(2), 'Max', 1);
set(h_orSlider(2), 'Min', -1);
set(h_orSliderRadio(1), 'Value', 1);
set(h_orEdit(2), 'String', num2str(obj.orientation(1)));
set(h_orEdit(4), 'String', num2str(obj.orientation(2)));
set(h_orEdit(6), 'String', num2str(obj.orientation(3)));

% callbacks

category = 'detector';

set(h_shapeRadio, 'Callback', {@detectorShapeRadio, mainFigure, ...
    h_shapeRadio, h_shapeEdit});
set(h_shapeEdit, 'Callback', {@detectorShapeEdit, mainFigure, ...
    h_shapeEdit, h_shapeRadio});
addlistener(h_shapeSlider(2), 'Value', 'PostSet', ...
    @(src, event)detectorShapeSlider(src, event, mainFigure, ...
    h_shapeSlider(3)));
set(h_shapeSlider(3), 'Callback', {@detectorShapeSliderEdit, ...
    mainFigure, h_shapeSlider});
set(h_shapeButton(1), 'Callback', {@detectorShapeButtonLoad, mainFigure});
set(h_shapeButton(2), 'Callback', {@processDlg, mainFigure});
set(h_shapeButton(3), 'Callback', {@detectorShapeButtonUnload, ...
    mainFigure});

subcategory = 'location';
addlistener(h_posSlider(2), 'Value', 'PostSet', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory));
set(h_posSlider(2), 'Callback', {@xyzSliderRelease, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory});
set(h_posSliderRadio, 'Callback', {@xyzSliderRadio, mainFigure, ...
    h_posSliderRadio, h_posSlider, category, subcategory});
set(h_posEdit, 'Callback', {@changeEdit, mainFigure, h_posEdit, ...
    h_posSlider, category, subcategory});

subcategory = 'orientation';
addlistener(h_orSlider(2), 'Value', 'PostSet', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory));
set(h_orSlider(2), 'Callback', {@xyzSliderRelease, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory});
set(h_orSliderRadio, 'Callback', {@xyzSliderRadio, mainFigure, ...
    h_orSliderRadio, h_orSlider, category, subcategory});
set(h_orEdit, 'Callback', {@changeEdit, mainFigure, h_orEdit, ...
    h_orSlider, category, subcategory});
set(h_orButton, 'Callback', {@orientationResetButton, mainFigure, ...
    h_orEdit, h_orSlider, category});

set(db.Handle, 'CloseRequestFcn', {@closeDlg, mainFigure, category, ...
    {'location', 'orientation'}});

end

%% callbacks specific to this dlg (other than process button)

function detectorShapeRadio(src, event, mainFigure, h_radio, h_edit)

obj = get(mainFigure, 'UserData');
if ~isnumeric(obj.detector.image)
    set(h_radio(1), 'Value', 1);
    set(h_radio(2), 'Value', 0);
    warndlg('Can''t have a circular image');
    return
end

set(h_radio(1:2), 'Value', 0);

switch get(src, 'String')
    case 'Rectangle'
        set(h_radio(1), 'Value', 1);
        set(h_edit(1), 'String', 'Height');
        set(h_edit(3), 'String', 'Width');
        set(h_edit(4), 'enable', 'on');
        set(h_edit(4), 'String', obj.detector.size(2));
        obj = changeObject(obj, 'detector', 'shape', 'rectangle');
    case 'Circle'
        set(h_radio(2), 'Value', 1);
        set(h_edit(1), 'String', 'Diameter');
        set(h_edit(3), 'String', '');
        set(h_edit(4), 'enable', 'off');
        set(h_edit(4), 'String', '');
        obj = changeObject(obj, 'detector', 'shape', 'circle');
end

set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end

function detectorShapeEdit(src, event, mainFigure, h_edit, h_radio)

obj = get(mainFigure, 'UserData');
newSize = editExtract(h_edit);
ind = radioExtract(h_radio);
if ind == 1
    updateFromEdit(mainFigure, newSize, 'detector', 'size', h_edit, true);
elseif ind == 2
    oldSize = obj.detector.size;
    if isnan(newSize(1))
        newSize = oldSize;
    end
    obj = changeObject(obj, 'detector', 'size', [newSize(1), oldSize(2)]);
    set(h_edit(2), 'String', num2str(obj.detector.size(1)));
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
end

end

function detectorShapeSlider(src, event, varargin)

mainFigure = varargin{1};
obj = get(mainFigure, 'UserData');

sliderVal = get(event.AffectedObject, 'Value');
obj = changeObject(obj, 'detector', 'faceAlpha', sliderVal);

set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end

function detectorShapeSliderEdit(src, event, mainFigure, h_slider)

sliderVal = editExtract(h_slider(3));
updateFromEdit(mainFigure, sliderVal, 'detector', 'faceAlpha', ...
    h_slider(3), true);

obj = get(mainFigure, 'UserData');
set(h_slider(2), 'Value', obj.detector.faceAlpha);

end

function detectorShapeButtonLoad(src, event, mainFigure)
importDetectorImage(mainFigure); % silly but necessary to keep as helper function and not make it a callback
end

function detectorShapeButtonUnload(src, event, mainFigure)

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'detector', 'image', -1);
obj = changeObject(obj, 'detector', 'faceAlpha', 0.75);
if isappdata(mainFigure, 'processDlg')
    db = getappdata(mainFigure, 'processDlg');
    if isvalid(db)
        delete(db.Figure)
    end
end
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end