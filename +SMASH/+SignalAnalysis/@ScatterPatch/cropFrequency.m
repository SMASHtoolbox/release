% cropFrequency Crop ScatterPatch object to range of frequencies
%
% This method crops the data in a ScatterPatch object to a range of
% frequencies chosen by the user.
%
% To graphically select the region:
%   cropFrequency(object);
% To specify the region:
%   cropFrequency(object, [minimumFrequency, maximumFrequency])
%
% May 2021 - Nathan Brown (npbrown@sandia.gov)
%
% See also ScatterPatch, removeBaseline

function cropFrequency(object, varargin)

% parse inputs

if nargin < 2
    label = 'Use zoom/pan to select desired frequency range';
    [~, frequencyRange] = getRegion(object, label);
else
    frequencyRange = varargin{1};
    if numel(frequencyRange) < 2
        frequencyRange = [-inf inf];
    end
end

frequencyRange = sort(frequencyRange);

% crop to frequency range

keepInd = object.Data(:,2) >= frequencyRange(1) & ...
    object.Data(:,2) <= frequencyRange(2);
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