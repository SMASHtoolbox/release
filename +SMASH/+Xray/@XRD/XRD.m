% XRD
%
% This class creates objects useful for designing and analyzing x-ray
% diffraction experiments. Though scripting is possible for advanced users, 
% this class primarily exists to support the user-friendly DENNIS program
% (available in the programs dropdown in SMASHtoolbox).
%
% Journal papers: https://doi.org/10.1088/1748-0221/19/07/P07030
%                 https://doi.org/10.1063/5.0267671
%
% Contact Nathan Brown (npbrown@sandia.gov) if you are interested in using
% the class for scripting.
%
% XRD objects are created via:
%    >> object = SMASH.Xray.XRD;
%       --> Automatically populates example setup
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
classdef XRD
    
    % note on units: crystal lattice size and x-ray wavelength must be in 
    % angstrom. X-ray energy must be in keV. Everything else is arbitrary 
    % but must be consistent. The only time an explicit unit system matters 
    % is when the code uses an image's grid to determine the detector size 
    % upon import; however, even that can easily be overwritten after 
    % import.
    
    properties (SetAccess = protected) % changing these changes computations
        crystal
        source
        detector
        calibration
        prediction
        results
        simulation
    end
    
    properties (SetAccess = public)
        externalUserData % enable users to store arbitrary data in the object
    end
    
    methods
        
        % constructor
        
        function obj = XRD
            
            % crystal
            
            obj.crystal.location = [0 0 0];
            obj.crystal.locationReference = obj.crystal.location;
            obj.crystal.orientation = [0 0 0];
            obj.crystal.orientationReference = obj.crystal.orientation;
            obj.crystal.orientationSystem = 'xyz';
            obj.crystal.angles = [90 90 90];
            obj.crystal.lengths = 3.58191*[1 1 1]; % angstrom
            obj.crystal.lengthsReference = obj.crystal.lengths;
            obj.crystal.elementNames = {'Cu'};
            obj.crystal.elementLocations = {[0 0 0; 0 .5 .5; ...
                .5 0 .5; .5 .5 0]};
            obj.crystal.elementOccupancies = 1;
            obj.crystal.CIF = 'Cubic Copper Example';
            obj.crystal.volumeRatio = 1;
            
            obj = generateUnitCell(obj);
            
            % x-ray source
            
            obj = changeObject(obj, 'source', 'location', [2 -10 0]);
            obj.source.locationReference = obj.source.location;
            obj.source.conversion = 12.3984198;
            obj = changeObject(obj, 'source', 'lambda', 1.5406); % angstrom
            obj = changeObject(obj, 'source', 'lambdaDistribution', 0.01);
            obj.source.K = 0.5; % unpolarized
            obj.source.twoThetaM = 0; % unmonochromatized
            
            % x-ray detector
            
            obj.detector.shape = 'rectangle';
            obj.detector.location = [80 60 0];
            obj.detector.locationReference = obj.detector.location;
            obj.detector.orientation = [0 0 0];
            obj.detector.orientationReference = obj.detector.orientation;
            obj.detector.size = [100 100]; % height/diameter and then width
            obj.detector.planePoints = [obj.detector.location(1), ...
                obj.detector.location(2), obj.detector.location(3) + ...
                obj.detector.size(1)/2; obj.detector.location(1) + ...
                obj.detector.size(2)/2, obj.detector.location(2), ...
                obj.detector.location(3)]; % [spot 1; spot 2]
            obj.detector.faceAlpha = 0.75;
            vecRef = obj.detector.planePoints - obj.detector.location;
            obj.detector.vecRef = vecRef./sqrt(sum(vecRef.^2,2));
            
            obj.detector.image = -1;
            obj.detector.importUnitConversion = nan; % no conversion
            obj.detector.imageHistory.original = -1;
            obj.detector.imageHistory.lastsave = -1;
            obj.detector.imageHistory.precrop = -1;
            obj.detector.imageHistory.prebackground = -1;
            obj.detector.imageHistory.premask = -1;
            obj.detector.imageHistory.prereversemask = -1;
            obj.detector.imageHistory.prescale = -1;
            obj.detector.imageHistory.preccfilter = -1;
            obj.detector.imageHistory.presmooth = -1;
            obj.detector.imageHistory.prebandpassfilter = -1;

            % calibration

            obj = changeObject(obj, 'calibration', 'type', 'detectorAuto');
            
            % prediction
            
            obj.prediction.type = 'powder';
            obj.prediction.option = 'default';
            obj.prediction.combinationTolerance = 0.001;
            obj.prediction.max_hkl = 10;
            obj.prediction.Lorentz = 'image';
             
            obj = deletePredictionAndResults(obj);
            
            % results
            
            obj.results.thetaResolution = 0.01;
            obj.results.average = true;
            obj.results.inverseLorentz = false;
            obj.results.theta = nan;
            obj.results.normalizedIntensity = nan;

            % simulation

            obj = setSimulationDefaults(obj);
            
        end    
        
        % public methods defined in separate files
        
        obj = generateUnitCell(obj);
        obj = generatehkl(obj, maxhkl);
        obj = readCIF(obj, fileName);
        obj = representhkl(obj, indC, len);
        obj = powderPredictor(obj, varargin);
        obj = changeObject(obj, category, changeType, varargin);
        obj = generatePrediction(obj);
        obj = deletePredictionAndResults(obj, varargin);
        obj = resetOrientation(obj, category);
        obj = importDetectorImage(obj, fileName);
        obj = combinePowder(obj);
        obj = findSpotLocations(obj, varargin);
        obj = generateResults(obj);
        [planeNormal, dist, n] = computePlaneValues(obj);
        obj = convertFromOld(obj);
        obj = runSimulation(obj);
        obj = deleteSimulation(obj);
        obj = setSimulationDefaults(obj);
        [obj, ang, rotVec] = alignAxis(obj,varargin);
        h = generatePredictionFigure(obj, varargin);
        obj = calROI(obj, varargin);
        obj = calThresh(obj);
        obj = calCC(obj);
        obj = calPOI(obj, varargin);
        [obj, score, gaInfo] = calSolve(obj);
        obj = calProcessImage(obj, varargin);
        obj = matchImage(obj)

    end

    % private methods

    methods (Access = private)
        obj = computeVolumeAnddCalcs(obj);
    end
    
    % private static methods
    
    methods (Access = private, Static = true)
        varargout = scatteringFactorComponents(varargin)
        varargout = rotationMatrix(varargin);
        varargout = findIntersection(varargin);
        varargout = findPixelCoordinates(varargin);
        varargout = extractLambdaRange(varargin);
    end
    
end

