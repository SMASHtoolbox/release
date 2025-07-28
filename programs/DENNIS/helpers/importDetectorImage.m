function importDetectorImage(mainFigure)

obj = get(mainFigure, 'UserData');

% query file

[file, path] = uigetfile({'*.img;*.tif;*.tiff;*.jpg;*.jpeg;*.png;*.bmp;*.mat', ...
    'Image Files'}, 'Choose detector image');
if isnumeric(file)
    return
end

% query use same mask

maskInd = [];
if ~isnumeric(obj.detector.imageHistory.premask) || ...
        ~isnumeric(obj.detector.imageHistory.prereversemask)
    qans = questdlg('Apply previous image mask to new image?', 'Apply Mask?', ...
        'Yes', 'No', 'Yes');
    if strcmpi(qans, 'yes')
        maskInd = obj.detector.image.Data <= 0;
    end
end

% query units

guiUnit = 1e-3; % mm (based on m)

listCell = {'ignore', '13 µm', '13.5 µm', '25 µm', '26 µm', '43.48 µm', ...
    '86.957 µm','100 µm', '200 µm', 'custom'};
convVec = [nan, 13e-6, 13.5e-6, 25e-6, 26e-6, 43.48e-6, 86.957e-6 100e-6, 200e-6, nan]; % based on m
[indx, tf] = listdlg('PromptString', {'Select pixel size'}, ...
    'SelectionMode', 'single', 'ListSize', [125 130], ...
    'ListString', listCell);
if ~tf
    conv = nan;
    warning('No selection - ignoring unit conversion')
elseif indx == length(listCell)
    an = inputdlg('Input pixel size (m)', 'Custom');
    if ~isempty(an)
        conv = str2double(an{1})/guiUnit;
    else
        warning('No selection - ignoring units')
        conv = nan;
    end
else
    conv = convVec(indx)/guiUnit;
end

obj = changeObject(obj, 'detector', 'importUnitConversion', conv);
           
% read file

fpath = fullfile(path, file);
[~, ~, ext] = fileparts(fpath);
if strcmpi(ext, '.mat')
    mat = load(fpath);
    varNames = fieldnames(mat);
    foundImageFlag = false;
    for ii = 1:length(varNames)
        if isa(mat.(varNames{ii}), 'SMASH.ImageAnalysis.Image')
            obj = changeObject(obj, 'detector', 'image', ...
                mat.(varNames{ii}));
            foundImageFlag = true;
            break
        elseif isa(mat.(varNames{ii}), 'SMASH.Xray.XRD')
            obj = changeObject(obj, 'detector', 'image', ...
                mat.(varNames{ii}).detector.image);
            foundImageFlag = true;
            break
        end
    end
    if ~foundImageFlag
        errordlg('No SMASH.ImageAnalysis.Image found in selected mat file');
    end
else
    obj = changeObject(obj, 'detector', 'image', fpath);       
end

% mask image

if ~isempty(maskInd)
    if all(size(maskInd) == size(obj.detector.image.Data))
        obj = processImage(obj, 'mask', maskInd);
    else
        errordlg('No mask applied: incompatible image sizes')
    end
end
    
% general update

obj = changeObject(obj, 'simulation', 'displayindennis', false);
set(mainFigure, 'UserData', obj);
updatePlotPredictionAnalysis(mainFigure);

% detector dlg update if necessary
        
badFlag = true;
if isappdata(mainFigure, 'detectorDlg')
    db = getappdata(mainFigure, 'detectorDlg');
    if isvalid(db)
        if ishandle(db.Handle)
            badFlag = false;
        end
    end
end
if badFlag
    return
end

set(findobj(db.Handle, 'Tag', 'shape1'), 'Value', 1);
set(findobj(db.Handle, 'Tag', 'shape2'), 'Value', 0);
set(findobj(db.Handle, 'Tag', 'size1'), 'String', ...
    num2str(obj.detector.size(1)));
set(findobj(db.Handle, 'Tag', 'size2'), 'String', ...
    num2str(obj.detector.size(2)));
set(findobj(db.Handle, 'Tag', 'size2'), 'enable', 'on');
set(findobj(db.Handle, 'Tag', 'label1'), 'String', 'Height');
set(findobj(db.Handle, 'Tag', 'label2'), 'String', 'Width');
        

end