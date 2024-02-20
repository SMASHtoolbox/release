% MASKSUBTRACT Mask and subtract data values in an image
%
% Interactive selection of mask and subsequent subtraction of masked data
% from image
%     >> object=mask(object) % interactive selection
%     >> object=mask(object,target) % interactively select region on a
%                                    specified target already displaying
%                                    the image (useful for some GUI
%                                    applications - target provides
%                                    reference for ROI but changes are made
%                                    to input image object)
%     >> object=mask(object,target, invertFlag) % specify inversion 
%                                               (default is false)
%     >> object=mask(object,ind) % manually input mask index
%     >> object=mask(object,ind, invertFlag) % specify inversion 
%                                               (default is false)
%     
% 
%

% created December 8, 2017 by Tommy Ao (Sandia National Laboratories)
% modified October 6, 2022 by Nathan Brown (Sandia National Laboratories)
% modified April, 2023 by Nathan Brown (SNL)
%
function object=maskSubtract(object, varargin)

% handle input
indInput = false;
if nargin == 1
    h=view(object,'show');
    title(h.axes, 'Select mask region'); 
    maskPoints = SMASH.ROI.selectROI({'Points', 'closed'}, h.axes);
    close(h.figure);
elseif ishandle(varargin{1})
    maskPoints = SMASH.ROI.selectROI({'Points', 'closed'}, varargin{1});
else
    indInput = true;
    in = varargin{1};
end

invert = false;
if nargin == 3
    invert = varargin{2};
end

% set masked region to 0
Data=object.Data;
if ~indInput
    if size(maskPoints.Data, 1) > 2
        Grid1=object.Grid1;
        Grid2=object.Grid2;
        xv=maskPoints.Data(:,1);
        yv=maskPoints.Data(:,2);
        xq=repmat(Grid1,length(Grid2),1);
        yq=repmat(Grid2,1,length(Grid1));
        in=inpolygon(xq,yq,xv,yv);
    else
        warning('Invalid mask select - no masking performed')
    end
end
if ~invert
    Data(in) = 0;
else
    Data(~in) = 0;
end
object.Data = Data;

end