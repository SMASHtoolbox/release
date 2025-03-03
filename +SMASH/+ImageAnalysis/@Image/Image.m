% This class creates Image objects designed for image analysis
% and visualization.  In these measurements, a two-dimensional image
% recorded on film/CCD/image plate etc. has a specific technical meaning.
% Depending on the measurement is taken, the x-axis and y-axis could
% be time, position, wavelength, energy, etc. The z-axis of the image is
% could be related to intensity or number of counts.
%
% The direct way of creating a Image object is to pass three input
% arrays:
%    >> object=Image(x,y,z);
% The first and second inputs define the independent arrays, which are
% stored as the object's "Grid1" and "Grid2" properties, respectively. The
% third  input defines dependent array and is stored as the object's "Data"
% property.  Typically, the number of elements for "x"/"y" should match the
% number of columns/rows in "z".  Inputs "x" and/or "y" can be empty,
% indicating that the corresponding Grid is a set of ascending integers;
% single "x" and/or "y" values indicate grid spacing (starting from 0).
%
% Image objects can also be created from an existing data file.
%    >> object=Image(); % interactive file selection
%    >> object=Image(filename,[format],[record]);
% The inputs "format" and "record" may be optional depending on the file's
% format and contents.  If the file name contains a wild card ('*.sda')
% that matches more than one file, the object is contructed from the sum of
% the individual files (consistent size required).
%
% See also SMASH.ImageAnalysis, SMASH.FileAccess.SupportedFormats
%

% created November 5, 2013 by Tommy Ao (Sandia National Laboratories)
% modified January 8, 2014 by Tommy Ao and Dan Dolan
%    -fixed issues with store/restore cycle
%    -allow multiple file load via structure/cell arrays
%    -various bug fixes
% updated April 21, 2014 by Daniel Dolan
%    -removed 'import' input requirement
% revised November 2, 2014 by Daniel Dolan
%    -simplified creator by using new DataClass paradigm
%
classdef Image < SMASH.General.DataClass
    %% properties
    properties (SetAccess={?SMASH.General.DataClass}) % core data
        Grid1 = [] % Independent array 1
        Grid2 = [] % Independent array 2
        LimitIndex1='all' % Region of interest on Grid1
        LimitIndex2='all' % Region of interest on Grid2
    end
    properties (SetAccess={?SMASH.General.DataClass},Hidden=true)
        Grid1Direction % 'normal' for increasing, 'reverse' for decreasing
        Grid1Uniform % true for uniform grid spacing
        Grid1Spacing % average grid spacing
        Grid2Direction % 'normal' for increasing, 'reverse' for decreasing
        Grid2Uniform % true for uniform grid spacing
        Grid2Spacing % average grid spacing
    end
    properties % display-related settings
        Grid1Label='Grid1' % XLabel used by view
        Grid2Label='Grid2' % YLabel used by view
        DataLim='auto' % Data range used by view ('auto' or [min max])
        DataScale='linear' % Data scaling used by view ('linear', 'log', or 'dB')    
    end
    properties (Hidden=true)
        History='';
    end
    %% constructor
    methods (Hidden=true)
        function object=Image(varargin)
            object=object@SMASH.General.DataClass(varargin{:}); 
            object=verifyGrid(object);
        end
    end
    methods (Hidden=true)
        varargin=makeGridUniform(varargin)
        varargout=verifyGrid(varargin)
        varargout=center_ellipse(varargin)
        varargout=center_points(varargin)
        varargout=region(varargin)
    end
    methods (Access=protected,Hidden=true)
        varargout=detail(varargin)
        varargout=explore(varargin)
        varargout=show(varargin)
        varargout=surface(varargin)
    end
    methods (Access=protected,Hidden=true)
        varargout=create(varargin)
        varargout=import(varargin) 
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% property setters
    methods
        function object=set.Grid1Label(object,value)
            if ischar(value)
                object.Grid1Label=value;
            else
                error('ERROR: Grid1Label must be character array');
            end
        end
        function object=set.Grid2Label(object,value)
            if ischar(value)
                object.Grid2Label=value;
            else
                error('ERROR: Grid2Label must be character array');
            end
        end        
        function object=set.DataLim(object,value)
            if strcmpi(value,'auto')
                % valid choice
            elseif isnumeric(value) && numel(value)==2
                % valid choice
            else
                error('ERROR: invalid DataLim');
            end
            object.DataLim=value;
        end
        function object=set.DataScale(object,value)
            if ~ischar(value)
                error('ERROR: invalid DataScale');
            end
            switch lower(value)
                case 'linear'
                    % valid choice
                case 'log'
                    % valid choice
                case {'db','decibel','decibels'}
                    value='dB';
                otherwise
                    error('ERROR: invalid DataScale');
            end
            object.DataScale=value;
        end                
    end
    
end
