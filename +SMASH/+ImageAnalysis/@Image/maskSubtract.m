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
ax = nan;
invert = false;
ind = nan;
roiInfo = {'closed'};
for ii = 1:numel(varargin)
    if ishandle(varargin{ii})
        ax = varargin{ii};
    elseif islogical(varargin{ii}) || isnumeric(varargin{ii})
        if numel(varargin{ii}) == 1
            invert = varargin{ii};
        else
            ind = varargin{ii};
        end
    elseif iscell(varargin{ii})
        roiInfo = varargin{ii};
    end
end

if any(isnan(ind))
    if ~ishandle(ax)
        h=view(object,'show');
        title(h.axes, 'Select mask region');
        maskPoints = SMASH.ROI.selectROI({'Points', roiInfo{1}}, h.axes);
        close(h.figure);
    else
        maskPoints = SMASH.ROI.selectROI({'Points', roiInfo{1}}, ax);
    end
    Grid1=object.Grid1;
    Grid2=object.Grid2;
    xv=maskPoints.Data(:,1);
    yv=maskPoints.Data(:,2);
    if strcmpi(roiInfo{1}, 'connected')
        switch lower(roiInfo{2})
            case 'y'
                xv = [xv-roiInfo{3}; xv(end:-1:1)+roiInfo{3}];
                yv = [yv; yv(end:-1:1)];
            case 'x'
                yv = [yv-roiInfo{3}; yv(end:-1:1)+roiInfo{3}];
                xv = [xv; xv(end:-1:1)];
        end
    end
    xq=repmat(Grid1,length(Grid2),1);
    yq=repmat(Grid2,1,length(Grid1));
    ind=inpolygon(xq,yq,xv,yv);
end

if ~invert
    object.Data(ind) = 0;
else
    object.Data(~ind) = 0;
end

end