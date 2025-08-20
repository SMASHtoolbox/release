function xyzSliderListener(src, event, varargin)

% have to use varargin to pass in variables to a listener (according to 
% MATLAB documentation):

mainFigure = varargin{1};
h_sliderStr = varargin{2};
h_radio = varargin{3};
h_edit = varargin{4};
category = varargin{5};
subcategory = varargin{6};

if nargin == 2+7
    extraOption = get(varargin{7}, 'Value');
    optFlag = true;
else
    optFlag = false;
end

updateEverything = false;

sliderVal = sliderExtract(event.AffectedObject, h_sliderStr);
ind = radioExtract(h_radio);

obj = get(mainFigure, 'UserData');
newRot = obj.(category).([subcategory, 'Reference']);
newRot(ind) = newRot(ind) + sliderVal;
if optFlag
   updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
       updateEverything, extraOption);
else
    updateFromEdit(mainFigure, newRot, category, subcategory, h_edit, ...
        updateEverything);
end
end