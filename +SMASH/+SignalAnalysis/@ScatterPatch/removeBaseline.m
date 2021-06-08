% removeBaseline Remove baseline signal from ScatterPatch object
%
% This method removes the baseline signal from a ScatterPatch object.
%
% To graphically select the baseline signal and start of removal region:
%   removeBaseline(object);
%   -User is first prompted to choose a representative baseline region.
%   The range of frequencies removed spans the minimum and maximum
%   values of the frequency components in the representative region.
%   -User is next prompted to choose a starting location for baseline
%   removal. The user should zoom/pan until the leftmost point of the plot 
%   corresponds to the beginning of the removal region.
% To additionally include a safety factor for determination of the range of
% frequencies to remove:
%   removeBaseline(object, safetyFactor)
%   -The range of frequencies removed is equal to span of the frequency
%   components in the representative region multiplied by safetyFactor
%
% Multiple options exist for specifying the frequency range to be removed
% and the time range of removal:
%   removeBaseline(object, [minimumFrequency, maximumFrequency], ...
%       [startTime, stopTime])
%   removeBaseline(object, [minimumFrequency, maximumFrequency], startTime)
%   removeBaseline(object, [minimumFrequency, maximumFrequency])
%
% May 2021 - Nathan Brown (npbrown@sandia.gov)
%
% See also ScatterPatch, cropFrequency

function removeBaseline(object, varargin)

% parse inputs

data = object.Data;
frequencyRange = nan;

if nargin < 2
    safetyFactor= 1;
else
    if numel(varargin{1}) < 2
        safetyFactor = varargin{1};
    else
        frequencyRange = varargin{1};
        if nargin > 2
            timeRange = varargin{2};
            if numel(timeRange) < 2
                timeRange = [timeRange, inf];
            end
        else
            timeRange = [-inf inf];
        end
    end
end

if isnan(frequencyRange)
    
    % get frequency range
    
    label = 'Use zoom/pan to select representative baseline region';
    [boundX, boundY] = getRegion(object, label);
    ind = data(:,1) >= boundX(1) & data(:,1) <= boundX(2) & ...
        data(:,2) >= boundY(1) & data(:,2) <= boundY(2);
    baseline = data(ind,2);
    frequencyRange = [min(baseline) , max(baseline)];
    oldWidth = diff(frequencyRange);
    widthChange = (safetyFactor * oldWidth) - oldWidth;
    frequencyRange(1) = frequencyRange(1) - widthChange/2;
    frequencyRange(2) = frequencyRange(2) + widthChange/2;
    
    % get baseline removal start time
    
    label = 'Use zoom/pan to set start of baseline removal region';
    boundX = getRegion(object, label);
    timeRange = [boundX(1), inf];
end

frequencyRange = sort(frequencyRange);
timeRange = sort(timeRange);

% remove baseline

keepInd = (data(:,2) < frequencyRange(1) | ...
    data(:,2) > frequencyRange(2)) | ...
    (data(:,1) < timeRange(1) | data(:,1) > timeRange(2));
object.Data = object.Data(keepInd,:);

end

function [boundX, boundY] = getRegion(object, label)

plot(object);
hfig = gcf; % need to change plot to output a handle
haxes = gca; % need to change plot to output a handle
title(haxes, label);
hc=uicontrol('Parent',hfig,...
    'Style','pushbutton','String',' Done ',...
    'Callback','delete(gcbo)');
waitfor(hc);
boundX = xlim;
boundY = ylim;
close(hfig);

end