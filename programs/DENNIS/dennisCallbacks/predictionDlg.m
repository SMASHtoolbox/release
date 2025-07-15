function predictionDlg(src, event)

%% dialog box creation

mainFigure = ancestor(src, 'figure', 'toplevel');
[db, ex] = createDlg(mainFigure, 'predictionDlg', 'dialog');
if ex
    return
end

db.Name = 'Prediction';

% prediction

h_label = addblock(db, 'text', 'Prediction');
h_radio = addblock(db, 'radio', {'Powder', 'Single-Crystal'});
h_edit = addblock(db, 'custom', {'edit', 'edit'}, ...
    {'Min I', 'Max hkl'});
h_button = addblock(db, 'button', 'Make Fig');
h_table = addblock(db, 'table', {'[ h k l ]', 'Wavelength (A)', 'm', ...
    '2θ (°)', 'I', 'Show?'}, {});

% determine scaling

GUIHeight = 640;
[p, f] = determineScaling(GUIHeight,.85);

% re-size whole GUI

pos = get(db.Handle, 'Position');
pos(3) = 800*p;
pos(4) = GUIHeight*p;
set(db.Handle, 'Position', pos);

%% re-positioning

% shape and size

startHeight = pos(4) - 60*p;

set(h_label, 'FontSize', 18*f);
set(h_label, 'Position', [10*p startHeight 200*p 50*p]);

offset = 13;
set(h_radio(1), 'FontSize', 12*f);
set(h_radio(2), 'FontSize', 12*f);
set(h_radio(1), 'Position', [10*p startHeight-offset 100*p 20*p]);
set(h_radio(2), 'Position', [110*p startHeight-offset 180*p 20*p]);

set(h_button, 'FontSize', 12);
set(h_button, 'Position', [250 startHeight-offset-10 110 40]);

offset2 = offset + 60*p;
set(h_edit(1), 'FontSize', 12*f);
set(h_edit(2), 'FontSize', 12*f);
set(h_edit(3), 'FontSize', 12*f);
set(h_edit(4), 'FontSize', 12*f);
set(h_edit(1), 'Position', [10*p startHeight-offset2 100*p 40*p]);
set(h_edit(2), 'Position', [10*p startHeight-offset2-25*p 100*p 40*p]);
set(h_edit(3), 'Position', [120*p startHeight-offset2 100*p 40*p]);
set(h_edit(4), 'Position', [120*p startHeight-offset2-25*p 100*p 40*p]);

offset3 = offset2 + 70*p;

set(h_table, 'FontSize', 12*f);
set(h_table(end), 'ColumnWidth', {125*p 125*p 125*p 125*p 125*p 125*p});
set(h_table(end), 'Position', [10*p 10*p 760*p 425*p]);
set(h_table(1), 'Position', [15*p startHeight-offset3 116*p 19*p]);
set(h_table(2), 'Position', [(15+125)*p startHeight-offset3 116*p 19*p]);
set(h_table(3), 'Position', [(15+125*2)*p startHeight-offset3 116*p 19*p]);
set(h_table(4), 'Position', [(15+125*3)*p startHeight-offset3 116*p 19*p]);
set(h_table(5), 'Position', [(15+125*4)*p startHeight-offset3 116*p 19*p]);
set(h_table(6), 'Position', [(15+125*5)*p startHeight-offset3 116*p 19*p]);

% re-position whole GUI

positionDlg(db, mainFigure);

%% callbacks and defaults

% defaults

obj = get(mainFigure, 'UserData');
objFilt = obj.externalUserData;
obj = obj.prediction;

if strcmpi(obj.type, 'powder')
    set(h_radio(1), 'value', 1);
elseif strcmpi(obj.type, 'single-crystal')
    set(h_radio(2), 'value', 1);
end

set(h_edit(2), 'string', num2str(objFilt.min_I_show));
set(h_edit(4), 'string', num2str(objFilt.max_hkl_show));

updatePlotPredictionAnalysis(mainFigure, 'predictionTable')

% callbacks

set(h_radio, 'Callback', {@predictionRadio, mainFigure, h_radio});
set(h_button, 'Callback', {@predictionButton, mainFigure});
set(h_edit, 'Callback', {@predictionEdit, mainFigure, h_edit});
set(h_table(end), 'CellEditCallback', {@predictionTableEdit, mainFigure});
set(h_table(end), 'CellSelectionCallback', {@predictionTableSelect, ...
    mainFigure}); % might want to change to key press

end

function predictionRadio(src, event, mainFigure, h_radio)

obj = get(mainFigure, 'UserData');
set(h_radio(1:2), 'Value', 0);

switch get(src, 'String')
    case 'Powder'
        set(h_radio(1), 'Value', 1);
        obj = changeObject(obj, 'prediction', 'type', 'powder');
    case 'Single-Crystal'
        set(h_radio(2), 'Value', 1);
        obj = changeObject(obj, 'prediction', 'type', 'single-crystal');
end

set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

end

function predictionButton(src, event, mainFigure)

obj = get(mainFigure, 'UserData');
generatePredictionFigure(obj);

end

function predictionEdit(src, event, mainFigure, h_edit)

newLims = editExtract(h_edit);

obj = get(mainFigure, 'UserData');
if isnan(newLims(1))
    newLims(1) = obj.externalUserData.min_I_show;
elseif newLims(1) < 1e-6
    newLims(1) = 1e-6;
elseif newLims(1) > 1
    newLims(1) = 1;
end
if isnan(newLims(2))
    newLims(2) = obj.externalUserData.max_hkl_show;
elseif newLims(2) < 1
    newLims(2) = 1;
end

obj.externalUserData.min_I_show = newLims(1);
obj.externalUserData.max_hkl_show = newLims(2);
set(h_edit(2), 'String', num2str(obj.externalUserData.min_I_show));
set(h_edit(4), 'String', num2str(obj.externalUserData.max_hkl_show));

if obj.externalUserData.max_hkl_show > obj.prediction.max_hkl
    obj = changeObject(obj, 'prediction', 'max_hkl', ...
        floor(obj.externalUserData.max_hkl_show));
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure);
else
    minI = obj.externalUserData.min_I_show;
    maxhkl = obj.externalUserData.max_hkl_show;
    I = obj.prediction.I;
    hkl = obj.prediction.hkl;
    displayInd = I >= minI & all(abs(hkl) <= maxhkl, 2);
    obj.externalUserData.displayInd = displayInd;
    set(mainFigure, 'UserData', obj);
    updatePlotPredictionAnalysis(mainFigure, 'predictionDisplay');
end

end

function predictionTableEdit(src, event, mainFigure)

tableData = get(src, 'Data');

if size(tableData, 1) > 1
    tableCheckedInd = cell2mat(tableData(:,6));
    rewriteTable = false;
    if event.Indices(1) == 1 % if All was clicked
        tableCheckedInd(:) = tableCheckedInd(1);
        rewriteTable = true;
    else
        if all(tableCheckedInd(2:end)) && ~tableCheckedInd(1)
            tableCheckedInd(1) = true;
            rewriteTable = true;
        elseif tableCheckedInd(1) && ~event.NewData
            tableCheckedInd(1) = false;
            rewriteTable = true;
        end
    end
    
    obj = get(mainFigure, 'UserData');
    checkedInd = obj.externalUserData.checkedInd;
    displayInd = obj.externalUserData.displayInd;
    checkedInd([true; displayInd]) = tableCheckedInd;
    
    obj.externalUserData.checkedInd = checkedInd;
    set(mainFigure, 'UserData', obj);
    
    if rewriteTable
        updatePlotPredictionAnalysis(mainFigure, 'predictionDisplay');
    else
        updatePlotPredictionAnalysis(mainFigure, 'predictionPlot');
    end
    
end

end

function predictionTableSelect(src, event, mainFigure)

indx = event.Indices;
indx(indx(:,1) == 1,:) = []; % not allowing an all highlight
indx(indx(:,2) == 6,:) = []; % not allowing plot? highlight

obj = get(mainFigure, 'UserData');

if isempty(indx)
    obj.externalUserData.clickedInd = false(size(...
        obj.externalUserData.displayInd));
else
    indx = indx(:,1) - 1;
    tableClickedInd = false(size(get(src, 'Data'), 1) - 1, 1);
    tableClickedInd(indx) = true;
    displayInd = obj.externalUserData.displayInd;
    clickedInd = obj.externalUserData.clickedInd;
    clickedInd(displayInd) = tableClickedInd;
    obj.externalUserData.clickedInd = clickedInd;
end

set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure, 'predictionPlot');

end