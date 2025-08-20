% SMOOTH Smooth the Image data over a local neighborhood
%
% Usage:
%   >> object=smooth(object,choice,value);
% "choice" can be 'mean', 'median', or 'kernel' (advanced users only)
% "value" is the smoothing neighborhood (e.g., [3 3]) or kernel weights.
%   >> object=smooth(object,choice,value,specifyRegion);
% "region" can be true, false, or logical index of ROI
%
% NOTE: neighborhoods and kernel arrays follow MATLAB image conventions.
% For example, the first column of a neighboard array refers to the
% *vertical* vertical smoothing: [11 5] indicates smoothing over 11
% vertical points and 5 horizontal points.
%
% See also IMAGE, bin, sharpen

% created July 27, 2012 by Daniel Dolan (Sandia National Laboratories)
% minor bug fixes on February 4, 2013 by Daniel Dolan
%   -corrected kernel normalization for mean filter
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
% modified July, 2023 by Nathan Brown (Sandia National Laboratories)
%
function object=smooth(object,choice,value,varargin)

% verify uniform grid
object=makeGridUniform(object);

% handle input
assert(nargin>=3,'ERROR: smoothing choice and value are required');
region = false;
if nargin > 3
    region = varargin{1};
end

% prompt user for ROI
ind = true(size(object.Data));
if numel(region) == 1
    if region
        h = view(object);
        roi = SMASH.ROI.selectROI({'Points', 'closed'}, h.axes);
        close(h.figure);
        if ~isempty(roi.Data)
            [x, y] = meshgrid(object.Grid1, object.Grid2);
            ind = inpolygon(x, y, roi.Data(:,1), roi.Data(:,2));
        end
    end
else
    ind = region;
end

% apply smoothing choice
switch lower(choice)
    case 'mean'
        N=numel(value);
        if N==1
            value=repmat(value,[1 2]);
        elseif N==2
            % do nothing
        else
            error('ERROR: invalid mean smoothing size');
        end
        if any(round(value)~=value) || any(value<1) || any(N>size(object.Data))
            error('ERROR: invalid mean smoothing size');
        end
        kernel=ones(value);
        kernel=kernel/sum(kernel(:));
        object=smooth(object,'kernel',kernel,ind);
    case 'median'
        newVal = localmedian(object.Data,value);
        object=replace(object, newVal(ind), ind);
    case 'kernel'
        if ~ismatrix(value)
            error('ERROR: invalid smoothing kernel');
        end
        newVal = conv2(object.Data,value,'same');
        object=replace(object, newVal(ind), ind);
    otherwise
        error('ERROR: invalid smoothing choice');
end

object=updateHistory(object);

end