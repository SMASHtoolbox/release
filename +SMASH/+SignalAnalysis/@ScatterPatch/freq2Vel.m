% UNDER CONSTRUCTION

function freq2Vel(object, wavelength, varargin)

if numel(object) > 1
    error('Result object arrays not supported')
end

data = object.RawData;

% manage options

option = struct('Reference', [], 'WindowCorrection', []);

try
    option=SMASH.Developer.options2struct(option,varargin{:});
catch ME
    throwAsCaller(ME);
end

if isempty(option.Reference)
    label = 'Use zoom/pan to select reference';
    [boundX, boundY] = getRegion(object, label);
    ind = data(:,1) >= boundX(1) & data(:,1) <= boundX(2) & ...
        data(:,2) >= boundY(1) & data(:,2) <= boundY(2) & ...
        logical(data(:,6));
    assert(any(ind), 'ERROR: No reference selected');
    data = data(ind,:);
    w = 1./data(:,4).^2;
    option.Reference = sum(w.*data(:,2))/sum(w);
end

if isempty(option.WindowCorrection)
    option.WindowCorrection = 1;
end

% convert data from frequency to velocity

shiftVal = -1*option.Reference;
scaleVal = wavelength/2/option.WindowCorrection;

shiftAndScaleAxis(object, 'Axis', 'y', 'Shift', shiftVal, 'Scale', ...
    scaleVal) 

end

function [boundX, boundY] = getRegion(object, label)

plot(object);
hfig = gcf; % need to change plot to output a handle
haxes = gca; % need to change plot to output a handle
caxis('auto')
title(haxes, label);
hc=uicontrol('Parent',hfig,...
    'Style','pushbutton','String',' Done ',...
    'Callback','delete(gcbo)');
waitfor(hc);
boundX = xlim;
boundY = ylim;
close(hfig);

end