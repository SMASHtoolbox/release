function simulationDlg(src, event)

%% dialog box creation

mainFigure = ancestor(src, 'figure', 'toplevel');
[db, ex] = createDlg(mainFigure, 'simulationDlg', 'dialog');
if ex
    return
end

db.Name = 'Simulation Parameters';

% general

h_generalLabel = addblock(db, 'text', 'General');
h_generalEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'Max hkl', 'Sim Size', 'Pixel Num'});
h_generalCheck = addblock(db, 'check', ' Uniform intensity?');
h_normalizeCheck = addblock(db, 'check', ' Normalized intensity?');

% mosaicity

h_mosaicityLabel = addblock(db, 'text', 'Mosaicity (± deg)');
h_mosaicityEdit = addblock(db, 'custom', {'edit', 'edit', 'edit'}, ...
    {'a', 'b', 'c'});
h_mosaicitySystemRadio = addblock(db, 'radio', {'abc', 'xyz'});
h_mosaicityDistributionRadio = addblock(db, 'radio', {'Gaussian', 'Uniform'});

% beam divergence

h_divergenceLabel = addblock(db, 'text', 'Beam Divergence');
h_divergenceEdit = addblock(db, 'custom', {'edit'}, ...
    {'Half-Angle (deg)'});
h_divergenceRadio = addblock(db, 'radio', {'Gaussian', 'Uniform'});

% gaussian spread

h_spreadLabel = addblock(db, 'text', 'Gaussian Spread');
h_spreadEdit = addblock(db, 'custom', {'edit'}, ...
    {'Half-Angle (deg)'});

% display

h_displayLabel = addblock(db, 'text', 'Display');
h_displayLim = addblock(db, 'custom', {'edit', 'edit'}, ...
    {'Min', 'Max'});
h_displaySlider = addblock(db, 'slider', 'Transparency');
h_displayImageCheck = addblock(db, 'check', ' Image?');
h_displayLabelsCheck = addblock(db, 'check', ' Labels?');
h_displayCurrentCheck = addblock(db, 'check', ' Updated?');

% simulate

h_simulateButton = addblock(db, 'button', 'Simulate');

% determine scaling parameters

GUIHeight = 885;
[p, f] = determineScaling(GUIHeight,.85);

% re-size whole GUI

pos = get(db.Handle, 'Position');
pos(3) = 300*p;
pos(4) = GUIHeight*p;
set(db.Handle, 'Position', pos);

%% re-positioning

% re-position whole GUI

positionDlg(db, mainFigure);

% set fonts

set(h_generalLabel, 'FontSize', 18*f);
set(h_mosaicityLabel, 'FontSize', 18*f);
set(h_divergenceLabel, 'FontSize', 18*f);
set(h_spreadLabel, 'FontSize', 18*f);
set(h_displayLabel, 'FontSize', 18*f);
set(h_simulateButton, 'FontSize', 18*f);
set(h_generalCheck, 'FontSize', 12*f);
set(h_normalizeCheck, 'FontSize', 12*f);
set(h_displayImageCheck, 'FontSize', 12*f);
set(h_displayLabelsCheck, 'FontSize', 12*f);
set(h_displayCurrentCheck, 'FontSize', 12*f);

for ii = 1:6
    set(h_generalEdit(ii), 'FontSize', 12*f);
    set(h_mosaicityEdit(ii), 'FontSize', 12*f);
    if ii < 5
        set(h_displayLim(ii), 'FontSize', 12*f);
    end
    if ii < 4
        set(h_displaySlider(ii), 'FontSize', 12*f);
    end
    if ii < 3
        set(h_mosaicitySystemRadio(ii), 'FontSize', 12*f);
        set(h_mosaicityDistributionRadio(ii), 'FontSize', 12*f);
        set(h_divergenceEdit(ii), 'FontSize', 12*f);
        set(h_divergenceRadio(ii), 'FontSize', 12*f);
        set(h_spreadEdit(ii), 'FontSize', 12*f);
    end
end

% general

startHeight = pos(4) - 60*p;
set(h_generalLabel, 'Position', [10*p startHeight 300*p 50*p]);
offset = 15*p;
set(h_generalEdit(1), 'Position', [10*p startHeight-offset 80*p 30*p]);
set(h_generalEdit(2), 'Position', [10*p startHeight-offset-20*p 80*p 30*p]);
set(h_generalEdit(3), 'Position', [100*p startHeight-offset 80*p 30*p]);
set(h_generalEdit(4), 'Position', [100*p startHeight-offset-20*p 80*p 30*p]);
set(h_generalEdit(5), 'Position', [190*p startHeight-offset 80*p 30*p]);
set(h_generalEdit(6), 'Position', [190*p startHeight-offset-20*p 80*p 30*p]);
set(h_generalCheck, 'Position', [10*p startHeight-offset-50*p 300*p 30*p]);
set(h_normalizeCheck, 'Position', [10*p startHeight-offset-25*p-50*p 300*p 30*p]);

% mosaicity

startHeight = startHeight - 160*p;
set(h_mosaicityLabel, 'Position', [10*p startHeight 300*p 50*p]);
offset = 15*p;
set(h_mosaicityEdit(1), 'Position', [10*p startHeight-offset 80*p 30*p]);
set(h_mosaicityEdit(2), 'Position', [10*p startHeight-offset-20*p 80*p 30*p]);
set(h_mosaicityEdit(3), 'Position', [100*p startHeight-offset 80*p 30*p]);
set(h_mosaicityEdit(4), 'Position', [100*p startHeight-offset-20*p 80*p 30*p]);
set(h_mosaicityEdit(5), 'Position', [190*p startHeight-offset 80*p 30*p]);
set(h_mosaicityEdit(6), 'Position', [190*p startHeight-offset-20*p 80*p 30*p]);
offset = offset + 55*p;
set(h_mosaicitySystemRadio(1), 'Position', [10*p startHeight-offset 50*p 30*p]);
set(h_mosaicitySystemRadio(2), 'Position', [70*p startHeight-offset 50*p 30*p]);
offset = offset + 27*p;
set(h_mosaicityDistributionRadio(1), 'Position', [10*p startHeight-offset 90*p 30*p]);
set(h_mosaicityDistributionRadio(2), 'Position', [110*p startHeight-offset 90*p 30*p]);

% beam divergence

startHeight = startHeight - 170*p;
set(h_divergenceLabel, 'Position', [10*p startHeight 200*p 50*p]);
offset = 15*p;
set(h_divergenceEdit(1), 'Position', [10*p startHeight-offset 150*p 30*p]);
set(h_divergenceEdit(2), 'Position', [10*p startHeight-offset-20*p 115*p 30*p]);
offset = offset + 55*p;
set(h_divergenceRadio(1), 'Position', [10*p startHeight-offset 90*p 30*p]);
set(h_divergenceRadio(2), 'Position', [110*p startHeight-offset 90*p 30*p])

% spread

startHeight = startHeight - 140*p;
set(h_spreadLabel, 'Position', [10*p startHeight 200*p 50*p]);
offset = 15*p;
set(h_spreadEdit(1), 'Position', [10*p startHeight-offset 150*p 30*p]);
set(h_spreadEdit(2), 'Position', [10*p startHeight-offset-20*p 115*p 30*p]);

% display

startHeight = startHeight - 115*p;
set(h_displayLabel, 'Position', [10*p startHeight 200*p 50*p]);
offset = 15*p;
set(h_displayLim(1), 'Position', [10*p startHeight-offset 80*p 30*p]);
set(h_displayLim(2), 'Position', [10*p startHeight-offset-20*p 80*p 30*p]);
set(h_displayLim(3), 'Position', [100*p startHeight-offset 80*p 30*p]);
set(h_displayLim(4), 'Position', [100*p startHeight-offset-20*p 80*p 30*p]);
offset = offset + 60*p;
set(h_displaySlider(1), 'Position', [10*p startHeight-offset, 200*p 30*p]);
set(h_displaySlider(2), 'Position', [10*p startHeight-offset-30*p 200*p 30*p]);
set(h_displaySlider(3), 'Position', [220*p startHeight-offset-30*p 55*p 30*p]);
set(h_displayImageCheck, 'Position', [10*p startHeight-offset-70*p 80*p 30*p]);
set(h_displayLabelsCheck, 'Position', [100*p startHeight-offset-70*p 80*p 30*p]);
set(h_displayCurrentCheck, 'Position', [190*p startHeight-offset-70*p 100*p 30*p]);

% simulate

startHeight = startHeight - 210*p;
set(h_simulateButton, 'Position', [60*p startHeight 150*p 50*p]);

%% defaults and callbacks

% defaults

obj = get(mainFigure, 'UserData');
objsim = obj.simulation;

set(h_generalEdit(2), 'String', num2str(objsim.max_hkl));
set(h_generalEdit(4), 'String', sprintf('%.0g',objsim.simulationSize));
set(h_generalEdit(6), 'String', sprintf('%.0g',objsim.pixelNum));
set(h_generalCheck(1), 'Value', objsim.uniformSpotIntensity);
set(h_normalizeCheck(1), 'Value', objsim.normalizedSpotIntensity);

set(h_mosaicityEdit(2), 'String', num2str(objsim.mosaicity(1)));
set(h_mosaicityEdit(4), 'String', num2str(objsim.mosaicity(2)));
set(h_mosaicityEdit(6), 'String', num2str(objsim.mosaicity(3)));

if strcmpi(objsim.mosaicitySystem, 'abc')
    set(h_mosaicitySystemRadio(1), 'Value', 1);
    str = 'abc';
else
    set(h_mosaicitySystemRadio(2), 'Value', 1);
    str = 'xyz';
end
set(h_mosaicityEdit(1), 'String', str(1));
set(h_mosaicityEdit(3), 'String', str(2));
set(h_mosaicityEdit(5), 'String', str(3));
if strcmpi(objsim.mosaicityDistribution, 'normal')
    set(h_mosaicityDistributionRadio(1), 'Value', 1);
else
    set(h_mosaicityDistributionRadio(2), 'Value', 1);
end

set(h_divergenceEdit(2), 'String', num2str(objsim.beamDivergenceHalfAngle));
if strcmpi(objsim.beamDivergenceDistribution, 'normal')
    set(h_divergenceRadio(1), 'Value', 1);
else
    set(h_divergenceRadio(2), 'Value', 1);
end

set(h_spreadEdit(2), 'String', num2str(objsim.gaussianSpreadHalfAngle));

set(h_displaySlider(2), 'Max', 1);
set(h_displaySlider(2), 'Min', 0);
set(h_displayImageCheck, 'Value', objsim.displayInDENNIS)
set(h_displayLabelsCheck, 'Value', objsim.displayLabelsInDENNIS)
set(h_displayCurrentCheck, 'Enable', 'off');

set(h_displayLim(2), 'Tag', 'lim1');
set(h_displayLim(4), 'Tag', 'lim2');
set(h_displaySlider(2), 'Tag', 'slider')
set(h_displaySlider(3), 'Tag', 'edit')
set(h_displayImageCheck, 'Tag', 'image')
set(h_displayLabelsCheck, 'Tag', 'labels')
set(h_displayCurrentCheck, 'Tag', 'current');

% update other values via helper

updatePlotPredictionAnalysis(mainFigure);

% callbacks

h = [h_generalEdit(2:2:6), h_generalCheck, h_mosaicityEdit(2:2:6), ...
    h_divergenceEdit(2), h_spreadEdit(2), h_normalizeCheck];
set(h, 'Callback', {@paramEdit, mainFigure, h, h_displayCurrentCheck});
set(h_mosaicitySystemRadio, 'Callback', {@radioChange, mainFigure, ...
    h_mosaicitySystemRadio, 'mosaicitySystem', h_displayCurrentCheck, ...
    h_mosaicityEdit});
set(h_mosaicityDistributionRadio, 'Callback', {@radioChange, mainFigure, ...
    h_mosaicityDistributionRadio, 'mosaicityDistribution', h_displayCurrentCheck});
set(h_divergenceRadio, 'Callback', {@radioChange, mainFigure, ...
    h_divergenceRadio, 'beamDivergenceDistribution', h_displayCurrentCheck});

set(h_displayLim, 'Callback', {@limChange, mainFigure, h_displayLim});
set(h_displayImageCheck, 'Callback', {@displayImage, mainFigure});
set(h_displayLabelsCheck, 'Callback', {@displayLabels, mainFigure});

addlistener(h_displaySlider(2), 'Value', 'PostSet', ...
    @(src, event)displaySlider(src, event, mainFigure, ...
    h_displaySlider(3)));
set(h_displaySlider(3), 'Callback', {@displaySliderEdit, ...
    mainFigure, h_displaySlider});

set(h_simulateButton, 'Callback', {@simulate, mainFigure, ...
    h_displayCurrentCheck, h_displayImageCheck});

end

%% callbacks

function paramEdit(src, event, mainFigure, h, h_displayCurrentCheck)

updateFromEdit(mainFigure, editExtract(h(1)), 'simulation', 'max_hkl', ...
    h(1), false);
updateFromEdit(mainFigure, editExtract(h(5:7)), 'simulation', 'mosaicity', ...
    h(5:7), false);
updateFromEdit(mainFigure, editExtract(h(8)), 'simulation', 'beamDivergenceHalfAngle', ...
    h(8), false);
updateFromEdit(mainFigure, editExtract(h(9)), 'simulation', 'gaussianSpreadHalfAngle', ...
    h(9), false);

obj = get(mainFigure, 'UserData');

obj = changeObject(obj, 'simulation', 'uniformspotintensity', ...
    logical(get(h(4), 'Value')));
obj = changeObject(obj, 'simulation', 'normalizedspotintensity', ...
    logical(get(h(10), 'Value')));
if contains(src.String, 'Normalized')
    obj.externalUserData.simLim = 'reset';
end
obj = changeObject(obj, 'simulation', 'simulationSize', editExtract(h(2)));
set(h(2), 'String', sprintf('%.0g',obj.simulation.simulationSize))
obj = changeObject(obj, 'simulation', 'pixelNum', editExtract(h(3)));
set(h(3), 'String', sprintf('%.0g',obj.simulation.pixelNum))

set(mainFigure, 'UserData', obj);
set(h_displayCurrentCheck, 'Value', obj.simulation.current)

end

function radioChange(src, event, mainFigure, h_radio, subCategory, ...
    h_displayCurrentCheck, varargin)

obj = get(mainFigure, 'UserData');
set(h_radio(1:2), 'Value', 0);
set(src, 'Value', 1);
str = get(src,'String');

if strcmpi(subCategory, 'mosaicitySystem')
    set(varargin{1}(1), 'String', str(1));
    set(varargin{1}(3), 'String', str(2));
    set(varargin{1}(5), 'String', str(3));
    switch str
        case 'abc'
            obj = changeObject(obj, 'simulation', subCategory, 'crystal');
        case 'xyz'
            obj = changeObject(obj, 'simulation', subCategory, 'cs');
    end
elseif strcmpi(subCategory, 'mosaicityDistribution')
    switch str
        case 'Gaussian'
            obj = changeObject(obj, 'simulation', subCategory, 'normal');
        case 'Uniform'
            obj = changeObject(obj, 'simulation', subCategory, 'uniform');
    end
elseif strcmpi(subCategory, 'beamDivergenceDistribution')
    switch str
        case 'Gaussian'
            obj = changeObject(obj, 'simulation', subCategory, 'normal');
        case 'Uniform'
            obj = changeObject(obj, 'simulation', subCategory, 'uniform');
    end
end

set(mainFigure, 'UserData', obj);
set(h_displayCurrentCheck, 'Value', obj.simulation.current)

end

function limChange(src, event, mainFigure, h)
newVal = editExtract(h);
obj = get(mainFigure, 'UserData');
if any(isnan(newVal))
    newVal = [0 1];
end
obj.externalUserData.simLim = newVal;
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function simulate(src, event, mainFigure, h_displayCurrentCheck, ...
    h_displayImageCheck)
set(h_displayCurrentCheck, 'Value', false);
set(h_displayImageCheck, 'Value', true);
obj = changeObject(get(mainFigure, 'UserData'), 'simulation', ...
    'displayInDENNIS', true);
obj = runSimulation(obj);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function displayImage(src, event, mainFigure)
obj = changeObject(get(mainFigure, 'UserData'), 'simulation', ...
    'displayindennis', get(src, 'Value'));
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function displayLabels(src, event, mainFigure)
obj = changeObject(get(mainFigure, 'UserData'), 'simulation', ...
    'displaylabelsindennis', get(src, 'Value'));
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');
end

function displaySlider(src, event, varargin)

mainFigure = varargin{1};
obj = get(mainFigure, 'UserData');

sliderVal = get(event.AffectedObject, 'Value');
obj = changeObject(obj, 'simulation', 'faceAlpha', sliderVal);

set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'detector');

end

function displaySliderEdit(src, event, mainFigure, h_slider)

sliderVal = editExtract(h_slider(3));
updateFromEdit(mainFigure, sliderVal, 'simulation', 'faceAlpha', ...
    h_slider(3), false);
updatePlotPredictionAnalysis(mainFigure, 'detector');

obj = get(mainFigure, 'UserData');
set(h_slider(2), 'Value', obj.simulation.faceAlpha);

end











