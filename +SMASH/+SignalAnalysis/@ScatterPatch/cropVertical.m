% cropVertical Crop ScatterPatch object to range of frequencies
%
% This method crops the data in a ScatterPatch object to a range of
% y-axis values chosen by the user. It essentially acts as a stripped down
% version of disable and is especially convenient for quickly graphically
% windowing the frequency data in high bandwidth signals.
%
% To graphically select the region:
%   cropVertical(object);
% To specify the region:
%   cropVertical(object, [minimumFrequency, maximumFrequency])
% To specify the region only for specific groups:
%   cropVertical(object, [minimumFrequency, maximumFrequency],
%   groupNumbers)
%
% May 2021 - Nathan Brown (npbrown@sandia.gov)
% June 2021 - Updated to match changes to ScatterPatch and enable group
% selection
%
% See also ScatterPatch, removeBaseline, disable, enable

function cropVertical(object, varargin)

% parse inputs

if numel(object) > 1
    error('Result object arrays not supported')
end

groupNumbers = object.GroupList;

if nargin < 2
    label = 'Use zoom/pan to select desired frequency range';
    [~, frequencyRange] = getRegion(object, label);
else
    frequencyRange = varargin{1};
    if numel(frequencyRange) < 2
        frequencyRange = [-inf inf];
    end
    if nargin > 2
        groupNumbers = varargin{2};
    end
end

frequencyRange = sort(frequencyRange);

% crop to frequency range

disableInd = object.RawData(:,2) - object.RawData(:,4) < frequencyRange(1) | ...
    object.RawData(:,2) + object.RawData(:,4) > frequencyRange(2);
disableInd = (disableInd & any(object.RawData(:,5) == groupNumbers, 2)) | ...
    ~logical(object.RawData(:,6));
object.RawData(:,6) = ~disableInd;

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