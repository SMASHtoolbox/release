% PROCESSIMAGE - apply image processing to loaded detector image
%
% This method applies image processing to the loaded detector image. It
% handles appropriate processing order (e.g. filtering on original image)
% and handles saving the image for resets.
%
% Usage:
%   >> obj = processImage(obj, processType, varargin)
%       -> varargin refers to the appropriate ImageAnalyis method inputs
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = processImage(obj, processType, varargin)

im = obj.detector.image;
if isnumeric(im)
    disp('No image to process')
    return
end

switch lower(processType)
    
    case 'crop'
        
        if isnumeric(obj.detector.imageHistory.precrop)
            obj.detector.imageHistory.precrop = im;
        end
        
        imOld = im;
        distOld = 2*sqrt(sum((obj.detector.planePoints - ...
            obj.detector.location).^2,2));
        
        im = crop(im, varargin{:});
        obj.detector.image = im;
        
        wFrac = (im.Grid1(end) - im.Grid1(1)) / ...
            (imOld.Grid1(end) - imOld.Grid1(1));
        hFrac = (im.Grid2(end) - im.Grid2(1)) / ...
            (imOld.Grid2(end) - imOld.Grid2(1));
        w = distOld(2)*wFrac;
        h = distOld(1)*hFrac;
        obj = changeObject(obj, 'detector', 'size', [h w]);
        
    case 'cropreset'
        
        if ~isnumeric(obj.detector.imageHistory.precrop)
            
            imOld = im;
            distOld = 2*sqrt(sum((obj.detector.planePoints - ...
                obj.detector.location).^2,2));
            
            im = obj.detector.imageHistory.precrop;
            obj.detector.image = im;
            
            wFrac = (im.Grid1(end) - im.Grid1(1)) / ...
                (imOld.Grid1(end) - imOld.Grid1(1));
            hFrac = (im.Grid2(end) - im.Grid2(1)) / ...
                (imOld.Grid2(end) - imOld.Grid2(1));
            w = distOld(2)*wFrac;
            h = distOld(1)*hFrac;
            obj = changeObject(obj, 'detector', 'size', [h w]);
        end
        
    case 'background'
        
        if isnumeric(obj.detector.imageHistory.prebackground)
            obj.detector.imageHistory.prebackground = im;
        end
        
        obj.detector.image = removeBackground(im, varargin{:});
        
    case 'backgroundreset'
        
        if ~isnumeric(obj.detector.imageHistory.prebackground)
            obj.detector.image = obj.detector.imageHistory.prebackground;
            obj.detector.imageHistory.prebackground = -1;
        end
        
    case 'mask'

        if nargin > 3 && varargin{end}
            if isnumeric(obj.detector.imageHistory.prereversemask)
                obj.detector.imageHistory.prereversemask = im;
            end
        else
            if isnumeric(obj.detector.imageHistory.premask)
                obj.detector.imageHistory.premask = im;
            end
        end
        
        obj.detector.image = maskSubtract(im, varargin{:});
        
    case 'maskreset'
        
        if ~isnumeric(obj.detector.imageHistory.premask)
            obj.detector.image = obj.detector.imageHistory.premask;
            obj.detector.imageHistory.premask = -1;
        end

    case 'reversemaskreset'

        if ~isnumeric(obj.detector.imageHistory.prereversemask)
            obj.detector.image = obj.detector.imageHistory.prereversemask;
            obj.detector.imageHistory.prereversemask = -1;
        end
        
    case 'scale'
        
        if isnumeric(obj.detector.imageHistory.prescale)
            obj.detector.imageHistory.prescale = obj.detector.size;
        end

        ax = varargin{1};
        if ishandle(ax)
            line = SMASH.ROI.selectROI({'Points', 'connected'}, ax);
            p1 = line.Data(1,:);
            p2 = line.Data(end,:);
            pixelDist = sqrt(sum((p2-p1).^2));
        else % diameter input
            pixelDist = ax;
        end
        an = inputdlg('Real Distance/Diameter (mm)', 'Real Distance?', ...
            1, {'75'});
        try
            realDist = str2double(an{1});
            pixelVal = realDist/pixelDist;
        catch
            warning('Bad input - no scaling performed');
            return
        end
        w = (max(im.Grid1) - min(im.Grid1))*pixelVal;
        h = (max(im.Grid2) - min(im.Grid2))*pixelVal;
        obj = changeObject(obj, 'detector', 'size', [h w]);
        
    case 'scalereset'
        
        if all(obj.detector.imageHistory.prescale > 0)
            obj = changeObject(obj, 'detector', 'size', ...
                obj.detector.imageHistory.prescale);
            obj.detector.imageHistory.prescale = -1;
        end

    case 'contourlimits'
        
        obj.detector.image.DataLim = [min(varargin{1}), ...
            max(varargin{1})];
        
    case 'contourlimitsreset'
        
        obj.detector.image.DataLim = 'auto';
        
    case 'ccfilter'
        
        if isnumeric(obj.detector.imageHistory.preccfilter)
            obj.detector.imageHistory.preccfilter = im;
        end
        
        obj.detector.image = ccFilter(im, varargin{:});
        
    case 'ccfilterreset'
        
        if ~isnumeric(obj.detector.imageHistory.preccfilter)
            obj.detector.image = obj.detector.imageHistory.preccfilter;
            obj.detector.imageHistory.preccfilter = -1;
        end
        
    case 'smooth'
        
        if isnumeric(obj.detector.imageHistory.presmooth)
            obj.detector.imageHistory.presmooth = im;
        end

        % filter on image

        imToFilt = obj.detector.image;
        imFilt = smooth(imToFilt, varargin{:});

        % apply pre-existing masking and backgrounding

        obj.detector.image = replace(imFilt, 0, im.Data == 0);
        
    case 'smoothreset'
        
        if ~isnumeric(obj.detector.imageHistory.presmooth)
            obj.detector.image = obj.detector.imageHistory.presmooth;
            obj.detector.imageHistory.presmooth = -1;
        end
        
    case 'bandpassfilter'
        
        if isnumeric(obj.detector.imageHistory.prebandpassfilter)
            obj.detector.imageHistory.prebandpassfilter = im;
        end

        % filter image, handling edge effects caused by masking

        zeroInd = im.Data == 0;
        im = replace(im, nan, zeroInd);
        im = replace(im, fillmissing(im.Data,'nearest'), ...
            true(size(im.Data)));
        im = bandpass(im, varargin{:});
        obj.detector.image = replace(im, 0, zeroInd);
        
    case 'filterreset'
        
        if ~isnumeric(obj.detector.imageHistory.prebandpassfilter)
            obj.detector.image = obj.detector.imageHistory.prebandpassfilter;
            obj.detector.imageHistory.prebandpassfilter = -1;
        end
        
    case 'save'
        
        obj.detector.imageHistory.lastsave = obj.detector.image;
        
    case 'reverttooriginal'
        
        obj.detector.image = obj.detector.imageHistory.original;
        obj.detector.imageHistory.precrop = -1;
        obj.detector.imageHistory.prebackground = -1;
        obj.detector.imageHistory.premask = -1;
        obj.detector.imageHistory.prereversemask = -1;
        obj.detector.imageHistory.preccfilter = -1;
        obj.detector.imageHistory.presmooth = -1;
        obj.detector.imageHistory.prebandpassfilter = -1;
        obj.detector.imageHistory.prescale = -1;
        
    case 'reverttosave'
        
        obj.detector.image = obj.detector.imageHistory.lastsave;
        obj.detector.imageHistory.precrop = -1;
        obj.detector.imageHistory.prebackground = -1;
        obj.detector.imageHistory.premask = -1;
        obj.detector.imageHistory.prereversemask = -1;
        obj.detector.imageHistory.preccfilter = -1;
        obj.detector.imageHistory.presmooth = -1;
        obj.detector.imageHistory.prebandpassfilter = -1;
        obj.detector.imageHistory.prescale = -1;

    case 'delete'

        obj.detector.image = -1;
        obj.detector.imageHistory.precrop = -1;
        obj.detector.imageHistory.prebackground = -1;
        obj.detector.imageHistory.premask = -1;
        obj.detector.imageHistory.prereversemask = -1;
        obj.detector.imageHistory.preccfilter = -1;
        obj.detector.imageHistory.presmooth = -1;
        obj.detector.imageHistory.prebandpassfilter = -1;
        obj.detector.imageHistory.prescale = -1;
        
    otherwise
        
        warning('Unrecognized image processing instructions. Nothing changed.')

end

end