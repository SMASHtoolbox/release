function sourceDlg(src, event)

%% dialog box creation

mainFigure = ancestor(src, 'figure', 'toplevel');
[db, ex] = createDlg(mainFigure, 'sourceDlg', 'dialog');
if ex
    return
end

db.Name = 'X-ray Source Parameters';

% position

h_posLabel = addblock(db, 'text', 'Position (mm)');
h_posSlider = addblock(db, 'slider', ' ');
h_posSliderRadio = addblock(db, 'radio', {'x', 'y', 'z'});
h_posEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});

% rotate

h_orLabel = addblock(db, 'text', 'Rotate (deg)');
h_orSlider = addblock(db, 'slider', ' ');
h_orSliderRadio = addblock(db, 'radio', {'x', 'y', 'z'});
h_orEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});
h_orCheck = addblock(db, 'check', ' Also rotate detector?'); 

% x-ray vector

h_vecLabel = addblock(db, 'text', 'Vector (mm)');
h_vecEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'x', 'y', 'z'});

% radiation

h_radLabel = addblock(db, 'text', 'Radiation');
h_radEditWaveVal = addblock(db, 'custom', {'edit', 'edit'}, ...
    {'Wavelength (A)', 'Energy (keV)'});
h_radEditWaveDist = addblock(db, 'custom', {'edit', 'edit'}, ...
    {'Value', 'Dist'});
h_radButton = addblock(db, 'button', 'Load');
h_radEditPol = addblock(db, 'custom', {'edit', 'edit'}, ...
    {'K', '2θ_M (deg)'});

% determine scaling

GUIHeight = 720;
[p, f] = determineScaling(GUIHeight,.85);

% re-size GUI

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
    set(h_vecEdit(ii), 'FontSize', 12*f);
    if ii < 5
        set(h_radEditWaveVal(ii), 'FontSize', 12*f);
        set(h_radEditWaveDist(ii), 'FontSize', 12*f);
        set(h_radEditPol(ii), 'FontSize', 12*f);
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

% rotate

startHeight = startHeight - 170*p;

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
set(h_orCheck, 'Position', [10*p startHeight-offset-20*p-40*p 200*p 30*p]);
set(h_orCheck, 'FontSize', 12*f)

% vector

startHeight = startHeight - 195*p;

set(h_vecLabel, 'FontSize', 18*f);
set(h_vecLabel, 'Position', [10*p startHeight 200*p 50*p]);
set(h_vecEdit(2), 'FontSize', 12*f);
set(h_vecEdit(2), 'Position', [10*p startHeight-60*p 200*p 30*p]);

offset = 15*p;
set(h_vecEdit(1), 'Position', [10*p startHeight-offset 60*p 30*p]);
set(h_vecEdit(2), 'Position', [10*p startHeight-offset-20*p 60*p 30*p]);
set(h_vecEdit(3), 'Position', [80*p startHeight-offset 60*p 30*p]);
set(h_vecEdit(4), 'Position', [80*p startHeight-offset-20*p 60*p 30*p]);
set(h_vecEdit(5), 'Position', [150*p startHeight-offset 60*p 30*p]);
set(h_vecEdit(6), 'Position', [150*p startHeight-offset-20*p 60*p 30*p]);

% radiation

startHeight2 = startHeight - 120*p;
offset = 15*p;

set(h_radLabel, 'FontSize', 18*f);
set(h_radLabel, 'Position', [10*p startHeight2 200*p 50*p]);
set(h_radEditWaveVal(1), 'Position', [60*p startHeight2-offset 155*p 30*p]);
set(h_radEditWaveVal(2), 'Position', [60*p startHeight2-offset-20*p 175*p 30*p]);
set(h_radEditWaveVal(3), 'Position', [245*p startHeight2-offset 155*p 30*p]);
set(h_radEditWaveVal(4), 'Position', [245*p startHeight2-offset-20*p 175*p 30*p]);
offset = offset+30*p;
set(h_radEditWaveDist(1), 'Position', [10*p startHeight2-offset+5*p 50*p 30*p]);
set(h_radEditWaveDist(2), 'Position', [60*p startHeight2-offset-20*p 175*p 30*p]);
set(h_radEditWaveDist(3), 'Position', [22*p startHeight2-offset-25*p 35*p 30*p]);
set(h_radEditWaveDist(4), 'Position', [245*p startHeight2-offset-20*p 175*p 30*p]);
offset = offset+62*p;
set(h_radButton, 'FontSize', 12*f);
set(h_radButton, 'Position', [58*p startHeight2-offset 70*p 40*p]);
offset = offset+30*p;
set(h_radEditPol(1), 'Position', [10*p startHeight2-offset 150*p 30*p]);
set(h_radEditPol(2), 'Position', [10*p startHeight2-offset-20*p 200*p 30*p]);
set(h_radEditPol(3), 'Position', [220*p startHeight2-offset 150*p 30*p]);
set(h_radEditPol(4), 'Position', [220*p startHeight2-offset-20*p 200*p 30*p]);

% re-position whole GUI

positionDlg(db, mainFigure);

%% callbacks and defaults

% defaults

obj = get(mainFigure, 'UserData');
obj = obj.source;

set(h_posSlider(2), 'Value', 0);
set(h_posSlider(3), 'String', '0');
set(h_posSlider(3), 'Enable', 'off');
set(h_posSlider(2), 'Max', 1);
set(h_posSlider(2), 'Min', -1);
set(h_posSliderRadio(1), 'Value', 1);
set(h_posEdit(2), 'Tag', 'xPos');
set(h_posEdit(4), 'Tag', 'yPos');
set(h_posEdit(6), 'Tag', 'zPos');

set(h_orSlider(2), 'Value', 0);
set(h_orSlider(3), 'String', '0');
set(h_orSlider(3), 'Enable', 'off');
set(h_orSlider(2), 'Max', 1);
set(h_orSlider(2), 'Min', -1);
set(h_orSliderRadio(1), 'Value', 1);
set(h_orEdit(2), 'Tag', 'xRot');
set(h_orEdit(4), 'Tag', 'yRot');
set(h_orEdit(6), 'Tag', 'zRot');

set(h_vecEdit(2), 'Tag', 'xs0');
set(h_vecEdit(4), 'Tag', 'ys0');
set(h_vecEdit(6), 'Tag', 'zs0');

set(h_radEditWaveVal(2), 'Tag', 'lambda');
set(h_radEditWaveVal(4), 'Tag', 'E');

set(h_radEditWaveDist(2), 'Tag', 'lambdaDistribution');
set(h_radEditWaveDist(4), 'Tag', 'EDistribution');

set(h_radEditPol(2), 'String', num2str(obj.K));
set(h_radEditPol(4), 'String', num2str(obj.twoThetaM));

% update tagged values in dlg

updatePlotPredictionAnalysis(mainFigure, 'source');

% callbacks

category = 'source';

subcategory = 'location';
addlistener(h_posSlider(2), 'Value', 'PostSet', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory));
set(h_posSlider(2), 'Callback', {@xyzSliderRelease, mainFigure, h_posSlider(3), ...
    h_posSliderRadio, h_posEdit, category, subcategory, ...
    {h_orSlider(2), h_orSlider(3)}, {'Value', 'String'}, {0, '0'}});
set(h_posSliderRadio, 'Callback', {@xyzSliderRadio, mainFigure, ...
    h_posSliderRadio, h_posSlider, category, subcategory});
set(h_posEdit, 'Callback', {@changeEdit, mainFigure, h_posEdit, ...
    h_posSlider, category, subcategory, ...
    {h_orSlider(2), h_orSlider(3)}, {'Value', 'String'}, {0, '0'}});

subcategory = 'rotate';
addlistener(h_orSlider(2), 'Value', 'PostSet', ...
    @(src,event)xyzSliderListener(src, event, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory, h_orCheck));
set(h_orSlider(2), 'Callback', {@xyzSliderRelease, mainFigure, h_orSlider(3), ...
    h_orSliderRadio, h_orEdit, category, subcategory, h_orCheck});
set(h_orSliderRadio, 'Callback', {@xyzSliderRadio, mainFigure, ...
    h_orSliderRadio, h_orSlider, category, subcategory});
set(h_orEdit, 'Callback', {@changeEdit, mainFigure, h_orEdit, ...
    h_orSlider, category, subcategory, h_orCheck});

set(h_vecEdit, 'Callback', {@sourceVectorEdit, mainFigure, h_vecEdit});

set(h_radEditWaveVal(2), 'Callback', {@sourceLambdaEdit, mainFigure});
set(h_radEditWaveVal(4), 'Callback', {@sourceEEdit, mainFigure});

set(h_radEditWaveDist(2), 'Callback', {@sourceLambdaDistributionEdit, mainFigure});
set(h_radEditWaveDist(4), 'Callback', {@sourceEDistributionEdit, mainFigure});

set(h_radEditPol(2), 'Callback', {@sourceKEdit, mainFigure});
set(h_radEditPol(4), 'Callback', {@sourcetwoThetaMEdit, mainFigure});

set(h_radButton, 'Callback', {@sourceRadButton, mainFigure})

set(db.Handle, 'CloseRequestFcn', {@closeDlg, mainFigure, category, ...
    'location'});

end

%% callbacks specific to this dlg

function sourceVectorEdit(src, event, mainFigure ,h)
updateFromEdit(mainFigure, editExtract(h), 'source', 's0', ...
    h, true);
end

function sourceKEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'K', ...
    src, true);
end

function sourcetwoThetaMEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'twoThetaM', ...
    src, true);
end

function sourceLambdaEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'lambda', ...
    src, true);
end

function sourceEEdit(src, event, mainFigure)
updateFromEdit(mainFigure, editExtract(src), 'source', 'E', ...
    src, true);
end

function sourceLambdaDistributionEdit(src, event, mainFigure)

lambdaStr = split(get(src, 'String'), '-');
lambdaStr = split(lambdaStr, '-');
dist = sscanf(lambdaStr{1}, '%g', 1);
if length(lambdaStr) > 1
    dist = [dist, sscanf(lambdaStr{2}, '%g', 1)];
end

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'source', 'lambdaDistribution', dist);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure);

end

function sourceEDistributionEdit(src, event, mainFigure)

EStr = split(get(src, 'String'), '-');
EStr = split(EStr, '-');
dist = sscanf(EStr{1}, '%g', 1);
if length(EStr) > 1
    dist = [dist, sscanf(EStr{2}, '%g', 1)];
end

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'source', 'EDistribution', dist);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure);

end

function sourceRadButton(src, event, mainFigure)

[file, path] = uigetfile('*.xls;*.xlsx;*.csv;*.mat', ...
    'Select distribution file');
if isnumeric(file)
    return
end
input = fullfile(path, file);
answ = questdlg('Wavelength (A) or Energy (keV)?', 'Distribution Type', ...
    'Wavelength (A)', 'Energy (keV)', 'Energy (keV)');
if isempty(answ)
    return
end
if contains(answ(1), 'W')
    choiceStr = 'lambdaDistribution';
else
    choiceStr = 'EDistribution';
end

[~, ~, ext] = fileparts(input);
if strcmpi(ext, '.mat')
    input = load(input);
    varNames = fieldnames(mat);
    if numel(varNames) < 1
        error('No variables found');
    elseif numel(varNames) > 1
        warning('Selecting first found variable');
    end
    input = input.(varNames{1});
end

obj = get(mainFigure, 'UserData');
obj = changeObject(obj, 'source', choiceStr, input);
set(mainFigure, 'UserData', obj);

updatePlotPredictionAnalysis(mainFigure);

end