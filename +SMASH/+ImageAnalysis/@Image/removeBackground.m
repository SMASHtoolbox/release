% REMOVEBACKGROUND Remove background noise from entire image
%
% This method computes the maximum signal in a user-selected ROI of a
% region containing only background and sets all values in object.Data 
% equal to or less than that maximum to 0. The method also sets all
% negative values to 0.
% This method is necessary for conditioning non-binary images for ccFind
% and ccFilter
%
% Usage:
%   >> object = removeBackground(object)
%     -> user selects ROI in a new window
%   >> object = removeBackground(object, target)
%     -> user selects ROI in a specified target (useful for GUIs)
%   >> object = removeBackground(object, ind)
%     -> user manually inputs an index containing the background region
%   >> object = removeBackground(object, threshold)
%     -> user manually inputs the background threshold as a scalar
%
% See also IMAGE MASKSUBTRACT CCFIND CCFILTER

% created October, 2022 by Nathan Brown (Sandia National Laboratories)
% modified April, 2023 by Nathan Brown (SNL)
% 

function obj=removeBackground(obj, varargin)

% handle input
graphicPick = true;
if nargin == 1
    h=view(obj,'show');
    set(h.figure, 'Position', get(0, 'Screensize'));
    title(h.axes, 'Select background region'); 
    backgroundPoints = SMASH.ROI.selectROI({'Points', 'convex'}, h.axes);
    close(h.figure);
elseif ishandle(varargin{1})
    backgroundPoints = SMASH.ROI.selectROI({'Points', 'convex'}, varargin{1});
elseif numel(varargin{1}) == 1
    graphicPick = false;
    in = obj.Data <= varargin{1};
else
    graphicPick = false;
    in = varargin{1};
end

% remove background
if graphicPick
    if size(backgroundPoints.Data, 1) > 2
        Grid1=obj.Grid1;
        Grid2=obj.Grid2;
        xv=backgroundPoints.Data(:,1);
        yv=backgroundPoints.Data(:,2);
        xq=repmat(Grid1,length(Grid2),1);
        yq=repmat(Grid2,1,length(Grid1));
        in=inpolygon(xq,yq,xv,yv);
    else
        warning('Invalid background select - no removal performed')
    end
end
maxBackground = max(max(obj.Data(in)));
obj.Data(obj.Data <= maxBackground | obj.Data <= 0) = 0;

end