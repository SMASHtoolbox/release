function object=smooth(object,choice,value)
%SMOOTH Smooth the ImageGroup data over a local neighborhood
%
% Usage:
%   >> object=smooth(object,choice,value);
% "choice" can be 'mean', 'median', or 'kernel' (advanced users only)
% "value" is the smoothing neighborhood (e.g., [3 3]) or kernel weights.
%
% NOTE: neighborhoods and kernel arrays follow MATLAB image conventions.
% For example, the first column of a neighboard array refers to the
% *vertical* vertical smoothing: [11 5] indicates smoothing over 11
% vertical points and 5 horizontal points.
%
% see also ImageGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

% split up ImageGroup
temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    tempObj{n}=smooth(temp{n},choice,value);
end

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});


end

