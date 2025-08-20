function xyzSliderRelease(src, event, varargin)

% In theory, I don't have to do all this. However, just in case MATLAB's
% listener functionality is a little buggy and the slider, edit box, and
% object somehow get out of sync, this should make sure they're all back on
% track upon the user's release of the slider.

% I'm also using this as the final update in updatePlotPredictionAnalysis

% Update: though it could be done in the main listener, I'm putting the
% reset handle stuff here to reduce the number of times it's called

% have to use varargin to pass in variables to a listener (according to 
% MATLAB documentation):

mainFigure = varargin{1};
h_sliderStr = varargin{2};
h_radio = varargin{3};
h_edit = varargin{4};
category = varargin{5};
subcategory = varargin{6};

if nargin == 2 + 7
    extraOption = get(varargin{7}, 'Value');
    optFlag = true;
else
    optFlag = false;
end

if nargin == 2 + 9
    resetHandle = varargin{7};
    resetType = varargin{8};
    resetValue = varargin{9};
    for ii = 1:length(resetHandle)
        set(resetHandle{ii}, resetType{ii}, resetValue{ii});
    end
end

updateEverything = true;

sliderVal = sliderExtract(src, h_sliderStr);
ind = radioExtract(h_radio);

obj = get(mainFigure, 'UserData');
newRot = obj.(category).([subcategory, 'Reference']);
newRot(ind) = newRot(ind) + sliderVal;
if optFlag
   updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
       updateEverything, extraOption);
   if extraOption && strcmpi(category, 'source') && strcmpi(subcategory, 'rotate')
       [db, ex] = createDlg(mainFigure, 'detectorDlg', 'dialog', false);
       if ex
           close(db.Handle);
       end
   end
else
    updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
        updateEverything);
end

end