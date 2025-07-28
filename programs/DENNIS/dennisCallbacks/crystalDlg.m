function crystalDlg(src, event)

%% dialog box creation

mainFigure = ancestor(src, 'figure', 'toplevel');
[db, ex] = createDlg(mainFigure, 'crystalDlg', 'dialog');
if ex
    return
end

db.Name = 'Crystal Parameters';

% position

h_posLabel = addblock(db, 'text', 'Position (mm)');
h_posSlider = addblock(db, 'slider', ' ');
h_posSliderRadio = addblock(db, 'radio', {'x', 'y', 'z'});
h_posEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});
h_posCheck = addblock(db, 'check', ' Maintain x-ray vector?'); 

% orientation

h_orLabel = addblock(db, 'text', 'Orientation (deg)');
h_orSlider = addblock(db, 'slider', ' ');
h_orSliderRadio = addblock(db, 'radio', {'x', 'y', 'z'});
h_orEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});
h_orSystemRadio = addblock(db, 'radio', {'xyz', 'abc'});
h_orButton = addblock(db, 'button', 'Reset');

% alignment

h_alignLabel = addblock(db, 'text', 'Alignment');
h_sourceLabel = addblock(db, 'text', 'Source:');
h_targetLabel = addblock(db, 'text', 'Target:');
h_alignSourceRadio = addblock(db, 'radio', {'a', 'b', 'c'});
h_alignTargetEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});
h_alignTargetRadio = addblock(db, 'radio', {'Lab', 'Crystal', 'Other Crystal'});
h_alignButton = addblock(db, 'button', 'Align');
h_alignCheck = addblock(db, 'check', ' Also rotate source and detector?'); 

% lattice

h_latLabel = addblock(db, 'text', 'Lattice');
h_latSizeSlider = addblock(db, 'slider', ' ');
h_latSizeSliderLabel = addblock(db, 'text', 'Volume Ratio');
h_latSizeEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'a', 'b', 'c'});
h_latSizeLabel = addblock(db, 'text', 'Angstrom');
h_latAngleEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'alpha', 'beta', 'gamma'});
h_latAngleLabel = addblock(db, 'text', 'deg');
h_latButton = addblock(db, 'button', 'Load');
h_latCifEdit = addblock(db, 'edit', ' ');

% determine scaling parameters

GUIHeight = 960;
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
delete(h_latCifEdit(1));
delete(h_latSizeSlider(1));

% change batch fonts

for ii = 1:length(h_posEdit)
    set(h_posEdit(ii), 'FontSize', 12*f);
    set(h_orEdit(ii), 'FontSize', 12*f);
    set(h_alignTargetEdit(ii), 'FontSize', 12*f);
    set(h_latSizeEdit(ii), 'FontSize', 12*f);
    set(h_latAngleEdit(ii), 'FontSize', 12*f);
    if ii < 4
        set(h_alignSourceRadio(ii), 'FontSize', 12*f);
        set(h_alignTargetRadio(ii), 'FontSize', 12*f);
    end
    if ii < 3
        set(h_orSystemRadio(ii), 'FontSize', 12*f);
    end
end

% position

startHeight = pos(4) - 60*p;

set(h_posLabel, 'FontSize', 18*f);
set(h_posLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_posSlider(2), 'Position', [10*p startHeight-20*p 200*p 30*p]);
set(h_posSlider(3), 'FontSize', 12*f);
set(h_posSlider(3), 'Position', [220*p startHeight-20*p 55*p 30*p]);
set(h_posSliderRadio(1), 'FontSize', 12*f);
set(h_posSliderRadio(2), 'FontSize', 12*f);
set(h_posSliderRadio(3), 'FontSize', 12*f);
set(h_posSliderRadio(1), 'Position', [290*p startHeight-15*p 36*p 20*p]);
set(h_posSliderRadio(2), 'Position', [332*p startHeight-15*p 36*p 20*p]);
set(h_posSliderRadio(3), 'Position', [374*p startHeight-15*p 36*p 20*p]);

offset = 60*p;
set(h_posEdit(1), 'Position', [10*p startHeight-offset 60*p 30*p]);
set(h_posEdit(2), 'Position', [10*p startHeight-offset-20*p 60*p 30*p]);
set(h_posEdit(3), 'Position', [80*p startHeight-offset 60*p 30*p]);
set(h_posEdit(4), 'Position', [80*p startHeight-offset-20*p 60*p 30*p]);
set(h_posEdit(5), 'Position', [150*p startHeight-offset 60*p 30*p]);
set(h_posEdit(6), 'Position', [150*p startHeight-offset-20*p 60*p 30*p]);
set(h_posCheck, 'Position', [10*p startHeight-offset-20*p-40*p 200*p 30*p]);
set(h_posCheck, 'FontSize', 12*f)

% orientation

startHeight = startHeight - 200*p;

set(h_orLabel, 'FontSize', 18*f);
set(h_orLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_orSlider(2), 'Position', [10*p startHeight-20*p 200*p 30*p]);
set(h_orSlider(3), 'FontSize', 12*f);
set(h_orSlider(3), 'Position', [220*p startHeight-20*p 55*p 30*p]);
set(h_orSliderRadio(1), 'FontSize', 12*f);
set(h_orSliderRadio(2), 'FontSize', 12*f);
set(h_orSliderRadio(3), 'FontSize', 12*f);
set(h_orSliderRadio(1), 'Position', [290*p startHeight-15*p 36*p 20*p]);
set(h_orSliderRadio(2), 'Position', [332*p startHeight-15*p 36*p 20*p]);
set(h_orSliderRadio(3), 'Position', [374*p startHeight-15*p 36*p 20*p]);
set(h_orEdit(2), 'FontSize', 12*f);
set(h_orEdit(2), 'Position', [10*p startHeight-60*p 200*p 30*p]);

offset = 60*p;
set(h_orEdit(1), 'Position', [10*p startHeight-offset 60*p 30*p]);
set(h_orEdit(2), 'Position', [10*p startHeight-offset-20*p 60*p 30*p]);
set(h_orEdit(3), 'Position', [80*p startHeight-offset 60*p 30*p]);
set(h_orEdit(4), 'Position', [80*p startHeight-offset-20*p 60*p 30*p]);
set(h_orEdit(5), 'Position', [150*p startHeight-offset 60*p 30*p]);
set(h_orEdit(6), 'Position', [150*p startHeight-offset-20*p 60*p 30*p]);

set(h_orSystemRadio(1), 'Position', [10*p startHeight-110*p 50*p 30*p]);
set(h_orSystemRadio(2), 'Position', [70*p startHeight-110*p 50*p 30*p]);

set(h_orButton, 'FontSize', 12*f);
set(h_orButton, 'Position', [10*p startHeight-150*p 70*p 40*p]);

% alignment

startHeight = startHeight - 230*p;

set(h_alignLabel, 'FontSize', 18*f);
set(h_alignLabel, 'Position', [10*p startHeight 200*p 50*p]);

set(h_sourceLabel, 'FontSize', 12*f);
set(h_sourceLabel, 'Position', [10*p startHeight-40*p 70*p 50*p]);
set(h_alignSourceRadio(1), 'Position', [(10+70)*p startHeight-9*p 36*p 20*p]);
set(h_alignSourceRadio(2), 'Position', [(10+70+42)*p startHeight-9*p 36*p 20*p]);
set(h_alignSourceRadio(3), 'Position', [(10+70+2*42)*p startHeight-9*p 36*p 20*p]);

set(h_targetLabel, 'FontSize', 12*f);
set(h_targetLabel, 'Position', [10*p startHeight-72*p 70*p 50*p]);
loffset = 70*p;
offset = 50*p;
set(h_alignTargetEdit(1), 'Position', [loffset+10*p startHeight-offset 60*p 30*p]);
set(h_alignTargetEdit(2), 'Position', [loffset+10*p startHeight-offset-20*p 60*p 30*p]);
set(h_alignTargetEdit(3), 'Position', [loffset+80*p startHeight-offset 60*p 30*p]);
set(h_alignTargetEdit(4), 'Position', [loffset+80*p startHeight-offset-20*p 60*p 30*p]);
set(h_alignTargetEdit(5), 'Position', [loffset+150*p startHeight-offset 60*p 30*p]);
set(h_alignTargetEdit(6), 'Position', [loffset+150*p startHeight-offset-20*p 60*p 30*p]);
set(h_alignTargetRadio(1), 'Position', [(10+70)*p startHeight-100*p 50*p 20*p]);
set(h_alignTargetRadio(2), 'Position', [(10+70+60)*p startHeight-100*p 100*p 20*p]);
set(h_alignTargetRadio(3), 'Position', [(10+70+140)*p startHeight-100*p 200*p 20*p]);

set(h_alignButton, 'FontSize', 12*f);
set(h_alignButton, 'Position', [(10+70)*p startHeight-150*p 70*p 40*p]);

set(h_alignCheck, 'Position', [(10+70+80)*p startHeight-150*p 250*p 30*p]);
set(h_alignCheck, 'FontSize', 12*f)

% lattice

startHeight = startHeight - 230*p;

set(h_latLabel, 'FontSize', 18*f);
set(h_latLabel, 'Position', [10*p startHeight 200*p 50*p]);

set(h_latSizeSlider(2), 'Position', [10*p startHeight-20*p 200*p 30*p]);
set(h_latSizeSlider(3), 'FontSize', 12*f);
set(h_latSizeSlider(3), 'Position', [220*p startHeight-20*p 55*p 30*p]);

set(h_latSizeSliderLabel,'FontSize', 10*f);
set(h_latSizeSliderLabel, 'Position', [285*p startHeight-30*p 100*p 30*p]);

startHeight = startHeight - 40*p;

set(h_latSizeEdit(1), 'Position', [10*p startHeight-20*p 60*p 30*p]);
set(h_latSizeEdit(2), 'Position', [10*p startHeight-45*p 60*p 30*p]);
set(h_latSizeEdit(3), 'Position', [80*p startHeight-20*p 60*p 30*p]);
set(h_latSizeEdit(4), 'Position', [80*p startHeight-45*p 60*p 30*p]);
set(h_latSizeEdit(5), 'Position', [150*p startHeight-20*p 60*p 30*p]);
set(h_latSizeEdit(6), 'Position', [150*p startHeight-45*p 60*p 30*p]);

set(h_latSizeLabel, 'FontSize', 10*f);
set(h_latSizeLabel, 'Position', [220*p startHeight-55*p 80*p 30*p]);

startHeight = startHeight - 100*p;
set(h_latAngleEdit(1), 'Position', [10*p startHeight 60*p 30*p]);
set(h_latAngleEdit(2), 'Position', [10*p startHeight-25*p 60*p 30*p]);
set(h_latAngleEdit(3), 'Position', [80*p startHeight 60*p 30*p]);
set(h_latAngleEdit(4), 'Position', [80*p startHeight-25*p 60*p 30*p]);
set(h_latAngleEdit(5), 'Position', [150*p startHeight 60*p 30*p]);
set(h_latAngleEdit(6), 'Position', [150*p startHeight-25*p 60*p 30*p]);

set(h_latAngleLabel, 'FontSize', 10*f);
set(h_latAngleLabel, 'Position', [220*p startHeight-35*p, 60*p 30*p]);

set(h_latButton, 'FontSize', 12*f);
set(h_latButton, 'Position', [10*p startHeight-80*p 70*p 40*p]);
set(h_latCifEdit(2), 'FontSize', 12*f);
set(h_latCifEdit(2), 'Position', [90*p startHeight-80*p, 320*p, 40*p])


% re-position whole GUI

positionDlg(db, mainFigure);

%% callbacks and defaults

% defaults

objAll = get(mainFigure, 'UserData');
obj = objAll.crystal;

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

str = obj.orientationSystem;
if strcmp(str, 'xyz')
    set(h_orSystemRadio(1), 'Value', 1);
else
    set(h_orSystemRadio(2), 'Value', 1);
end
set(h_orEdit(1), 'String', str(1));
set(h_orEdit(3), 'String', str(2));
set(h_orEdit(5), 'String', str(3));
set(h_orSliderRadio(1), 'String', str(1));
set(h_orSliderRadio(2), 'String', str(2));
set(h_orSliderRadio(3), 'String', str(3));

set(h_alignSourceRadio(1), 'Value', 1);
set(h_alignTargetRadio(1), 'Value', 1);
set(h_alignTargetEdit(2), 'String', '1');
set(h_alignTargetEdit(4), 'String', '0');
set(h_alignTargetEdit(6), 'String', '0');

set(h_latSizeSlider(2), 'Value', obj.volumeRatio);
set(h_latSizeSlider(3), 'String', num2str(obj.volumeRatio));
set(h_latSizeSlider(2), 'Max', 1.9);
set(h_latSizeSlider(2), 'Min', 0.1);
set(h_latSizeEdit(2), 'String', num2str(obj.lengths(1)));
set(h_latSizeEdit(4), 'String', num2str(obj.lengths(2)));
set(h_latSizeEdit(6), 'String', num2str(obj.lengths(3)));
set(h_latSizeEdit(2), 'Tag', 'a');
set(h_latSizeEdit(4), 'Tag', 'b');
set(h_latSizeEdit(6), 'Tag', 'c');

set(h_latAngleEdit(2), 'String', num2str(obj.angles(1)));
set(h_latAngleEdit(4), 'String', num2str(obj.angles(2)));
set(h_latAngleEdit(6), 'String', num2str(obj.angles(3)));
set(h_latAngleEdit(2), 'Tag', 'alpha');
set(h_latAngleEdit(4), 'Tag', 'beta');
set(h_latAngleEdit(6), 'Tag', 'gamma');

set(h_latCifEdit(2), 'String', fliplr(strtok(fliplr(obj.CIF), '\/')));
set(h_latCifEdit(2), 'enable', 'off');

% callbacks

category = 'crystal';

subcategory = 'location';
addlistener(h_posSlider(2), 'Value', 'PostSet', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory, h_posCheck));
set(h_posSlider(2), 'Callback', {@xyzSliderRelease, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory, h_posCheck});
set(h_posSliderRadio, 'Callback', {@xyzSliderRadio, mainFigure, ...
    h_posSliderRadio, h_posSlider, category, subcategory});
set(h_posEdit, 'Callback', {@changeEdit, mainFigure, h_posEdit, ...
    h_posSlider, category, subcategory, h_posCheck});

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
set(h_orSystemRadio, 'Callback', {@orRadioChange, mainFigure, ...
    h_orSystemRadio, h_orEdit, h_orSlider, h_orSliderRadio});
set(h_orButton, 'Callback', {@orientationResetButton, mainFigure, ...
    h_orEdit, h_orSlider, category});

set(h_alignSourceRadio, 'Callback', {@alignSourceRadioChange, ...
    h_alignSourceRadio});
set(h_alignTargetRadio, 'Callback', {@alignTargetRadioChange, ...
    h_alignTargetRadio, h_alignTargetEdit});
set(h_alignButton, 'Callback', {@alignButton, mainFigure, ...
    h_alignSourceRadio, h_alignTargetRadio, h_alignTargetEdit, ...
    h_orEdit, h_orSlider, h_orSliderRadio, h_alignCheck});

addlistener(h_latSizeSlider(2), 'Value', 'PostSet', ...
    @(src,event)latSizeSliderListener(src, event, mainFigure, h_latSizeSlider(3), ...
    h_latSizeEdit));
set(h_latSizeSlider(2), 'Callback', {@latSizeSliderRelease, mainFigure, ...
    h_latSizeSlider(3), h_latSizeEdit});
set(h_latSizeSlider(3), 'Callback', {@latSizeSliderEdit, ...
    mainFigure, h_latSizeSlider});
set(h_latSizeEdit, 'Callback', {@crystalLatSizeEdit, mainFigure, h_latSizeEdit, ...
    category, 'lengths', h_latSizeSlider});
set(h_latAngleEdit, 'Callback', {@crystalLatAngleEdit, mainFigure, ...
    h_latAngleEdit, category, 'angles', h_orSlider, h_orEdit, ...
    h_latSizeSlider});

set(h_latButton, 'Callback', {@crystalLatButton, mainFigure, ...
    h_latCifEdit(2), h_orSlider, h_orEdit, h_latSizeSlider});

set(db.Handle, 'CloseRequestFcn', {@closeDlg, mainFigure, category, ...
    {'location', 'orientation'}});

end

%% callbacks specific to this dlg

function orRadioChange(src, event, mainFigure, h_radio, h_edit, h_slider, ...
    h_sliderRadio)

set(h_radio(1:2), 'Value', 0);
set(src,'Value',1)

obj = get(mainFigure, 'UserData');
str = get(src, 'String');
obj = changeObject(obj, 'crystal', 'orientationSystem', str);

set(h_edit(1), 'String', str(1));
set(h_edit(3), 'String', str(2));
set(h_edit(5), 'String', str(3));
set(h_sliderRadio(1), 'String', str(1));
set(h_sliderRadio(2), 'String', str(2));
set(h_sliderRadio(3), 'String', str(3));

set(h_edit(2), 'String', num2str(obj.crystal.orientation(1)));
set(h_edit(4), 'String', num2str(obj.crystal.orientation(2)));
set(h_edit(6), 'String', num2str(obj.crystal.orientation(3)));
set(h_slider(2), 'Value', 0);
set(h_slider(3), 'String', '0');
set(h_sliderRadio(2:3), 'Value', 0);
set(h_sliderRadio(1), 'Value', 1)

set(mainFigure, 'UserData', obj);
 
end

function alignSourceRadioChange(src, event, h_radio)

set(h_radio(1:3), 'Value', 0);
set(src,'Value',1)
 
end

function alignTargetRadioChange(src, event, h_radio, h_edit)

set(h_radio(1:3), 'Value', 0);
set(src,'Value',1)

str = get(src, 'String');

if strcmpi(str, 'lab')
    set(h_edit(1), 'String', 'x');
    set(h_edit(3), 'String', 'y');
    set(h_edit(5), 'String', 'z');
else
    set(h_edit(1), 'String', 'a');
    set(h_edit(3), 'String', 'b');
    set(h_edit(5), 'String', 'c');
end
 
end

function alignButton(src, event, mainFigure, ...
    h_alignSourceRadio, h_alignTargetRadio, h_alignTargetEdit, ...
    h_orEdit, h_orSlider, h_orSliderRadio, h_alignCheck)

obj = get(mainFigure, 'UserData');

if get(h_alignSourceRadio(1),'Value')
    ind = 1;
elseif get(h_alignSourceRadio(2),'Value')
    ind = 2;
elseif get(h_alignSourceRadio(3),'Value')
    ind = 3;
end

targetVec = editExtract(h_alignTargetEdit);
if any(isnan(targetVec)) || ~any(targetVec) || any(isinf(targetVec))
    errordlg('Invalid Input');
    return
end

if get(h_alignTargetRadio(2),'Value')
    targetVec = sum(targetVec' .* obj.crystal.vectors,1);
elseif get(h_alignTargetRadio(3),'Value')
    [file, path] = uigetfile('*.mat');
    if isnumeric(file)
        return
    end
    targetObj = load(fullfile(path, file),'obj');
    targetObj = targetObj.obj;
    targetVec = sum(targetVec' .* targetObj.crystal.vectors,1);
end

[obj, ang, rotVec] = alignAxis(obj, ind, targetVec);
if get(h_alignCheck, 'Value')
    obj = changeObject(obj, 'source', 'rotate', ang, true, rotVec);
    [db, ex] = createDlg(mainFigure, 'detectorDlg', 'dialog', false);
    if ex
        close(db.Handle);
    end
    [db, ex] = createDlg(mainFigure, 'sourceDlg', 'dialog', false);
    if ex
        close(db.Handle);
    end
end

set(mainFigure, 'UserData', obj);

set(h_orEdit(2), 'String', num2str(obj.crystal.orientation(1)));
set(h_orEdit(4), 'String', num2str(obj.crystal.orientation(2)));
set(h_orEdit(6), 'String', num2str(obj.crystal.orientation(3)));
set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'String', '0');
set(h_orSliderRadio(2:3), 'Value', 0);
set(h_orSliderRadio(1), 'Value', 1)

updatePlotPredictionAnalysis(mainFigure);

end

function latSizeSliderListener(src, event, varargin)

% have to use varargin to pass in variables to a listener (according to 
% MATLAB documentation):

mainFigure = varargin{1};
h_sliderStr = varargin{2};

sliderVal = sliderExtract(event.AffectedObject, h_sliderStr, false);

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'crystal', 'volumeratio', sliderVal);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure, 'crystal');

end

function latSizeSliderRelease(src, event, varargin)

% serves the same function as xyzSliderRelease

mainFigure = varargin{1};
h_sliderStr = varargin{2};

sliderVal = sliderExtract(src, h_sliderStr, false);

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'crystal', 'volumeratio', sliderVal);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure);

end

function latSizeSliderEdit(src, event, mainFigure, h_slider)

sliderVal = editExtract(h_slider(3));
if isnan(sliderVal) || sliderVal < h_slider(2).Min || ...
        sliderVal > h_slider(2).Max
    sliderVal = h_slider(2).Value;
end
obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'crystal', 'volumeratio', sliderVal);
set(mainFigure, 'UserData', obj);
set(h_slider(2), 'Value', obj.crystal.volumeRatio);
set(h_slider(3), 'String', num2str(obj.crystal.volumeRatio));

updatePlotPredictionAnalysis(mainFigure);

end

function crystalLatAngleEdit(src, event, mainFigure, h_edit, category, ...
    subcategory, h_orSlider, h_orEdit, h_latSizeSlider)

new = editExtract(h_edit);
updateFromEdit(mainFigure, new, category, subcategory, h_edit, true);

obj = get(mainFigure, 'UserData');
set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'String', '0');
set(h_orEdit(2), 'String', num2str(obj.crystal.orientation(1)));
set(h_orEdit(4), 'String', num2str(obj.crystal.orientation(2)));
set(h_orEdit(6), 'String', num2str(obj.crystal.orientation(3)));

set(h_latSizeSlider(2), 'Value', obj.crystal.volumeRatio);
set(h_latSizeSlider(3), 'String', num2str(obj.crystal.volumeRatio));
set(mainFigure, 'UserData', obj);

end

function crystalLatSizeEdit(src, event, mainFigure, h_edit, category, ...
    subcategory, h_latSizeSlider)

new = editExtract(h_edit);
updateFromEdit(mainFigure, new, category, subcategory, h_edit, true);

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'crystal', 'lengthsreference', obj.crystal.lengths);
set(h_latSizeSlider(2), 'Value', obj.crystal.volumeRatio);
set(h_latSizeSlider(3), 'String', num2str(obj.crystal.volumeRatio));
set(mainFigure, 'UserData', obj);

end

function crystalLatButton(src, event, mainFigure, h_edit, h_orSlider, ...
    h_orEdit, h_latSizeSlider)

[file, path] = uigetfile('*.cif');
if isnumeric(file)
    return
end
cifPath = fullfile(path, file);

try
    obj = get(mainFigure, 'UserData');
    obj = changeObject(obj, 'crystal', 'CIF', cifPath);
catch
    errordlg('Failed to load CIF File')
    return
end

set(mainFigure, 'UserData', obj);
set(h_edit, 'String', fliplr(strtok(fliplr(obj.crystal.CIF), '\/')));
set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'String', '0');
set(h_orEdit(2), 'String', num2str(obj.crystal.orientation(1)));
set(h_orEdit(4), 'String', num2str(obj.crystal.orientation(2)));
set(h_orEdit(6), 'String', num2str(obj.crystal.orientation(3)));
set(h_latSizeSlider(2), 'Value', obj.crystal.volumeRatio);
set(h_latSizeSlider(3), 'String', num2str(obj.crystal.volumeRatio));

updatePlotPredictionAnalysis(mainFigure);

end