% CALPROCESSIMAGE - process detector image for detectorManual calibration
%
% This method processes the detector image to aid in connected component
% filtering for the detectorManual calibration.
%
% Usage:
%   >> obj = calSolve(obj)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function obj = calProcessImage(obj, processType, varargin)

% input parsing

im = obj.detector.image;
assert(~isnumeric(im), 'No image')

% code

switch lower(processType)
        
    case 'background'
        
        if nargin > 2
            warning('Ignoring threshold input - using value in opts');
        end
        im = obj.detector.image;
        obj.calibration.processedImage = removeBackground(im, ...
            obj.calibration.opts.threshold);

    case 'mask' % for split, use input of {'connected', dir, width}
        
        if ~isnumeric(obj.calibration.processedImage)
            im = obj.calibration.processedImage;
        else
            im = obj.detector.image;
        end
        obj.calibration.processedImage = maskSubtract(im, varargin{:});
        
    case 'reset'
        
        obj.calibration.processedImage = obj.detector.image;
        
    otherwise
        
        error('Unrecognized image processing instructions. Nothing changed.')

end

end