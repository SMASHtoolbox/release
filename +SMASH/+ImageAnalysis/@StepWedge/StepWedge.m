%
% This class manages analysis and application of step wedge measurements.
% Step wedge measurements characterize the nonlinear response of film.
% StepWedge objects are used in conjuction with Image objects: the step
% wedge measurement linearizes other measurements performed on the same
% type of film.
%
% StepWedge objects are usually created from a data file.
%     >> object=StepWedge(filename,format); % single-record files
%     >> object=StepWedge(filename,format,record); % multi-record files
% The object proves methods for
%     -Viewing for quality and orientation verification.
%     -Rotating for alignment with the horizontal axes.
% *NOTE* : auto rotate*
%
%     -Cleaning local artifacts.
%     -Cropping regions outside the wedge.
% Almost all step wedge files require some degree of cropping; the other
% methods are typically optional.
% 
% When a satisfactory step wedge image is achieved, the object is:
%     -Analyzed to associate exposure with optical density
%     -Applied to an Image object
% Step wedges are associated with images derived from the same type of film
% undergoing similar processing.  Ideally, the step wedge measurement is
% performed on film from the same batch as the measurements of interest and
% developed simultaneously.  
%
% See also SMASH.ImageAnalysis, SMASH.ImageAnalysis.Image,
% SMASH.FileAccess.SupportedFormats
%

%
% created August 28, 2015 by Daniel Dolan (Sandia National Laboratories)
%
%%
classdef StepWedge
    %%
    properties        
        Measurement % Measured step wedge (Image object)
    end
    properties (SetAccess=protected)
        Settings % Analysis settings (structure)
        Results % Analysis results (structure)       
    end
    properties (Access=protected,Hidden=true)        
        Cropped=false;
        Analyzed=false;
    end
    %% constructor
    methods (Hidden=true)
        function object=StepWedge(varargin)
            if nargin==0
                temp=SMASH.ImageAnalysis.Image();
                object=SMASH.ImageAnalysis.StepWedge(temp);
            elseif strcmpi(varargin{1},'-empty')
                % do nothing
            elseif ischar(varargin{1})
                [~,~,ext]=fileparts(varargin{1});
                if strcmp(ext,'.sda')
                    temp=SMASH.FileAccess.readFile(varargin{:});                    
                else
                    temp=SMASH.ImageAnalysis.Image(varargin{:});
                end
                try
                    object=SMASH.ImageAnalysis.StepWedge(temp);
                catch
                    error('ERROR: unable to construct object from SDA record');
                end
            elseif isobject(varargin{1})
                switch class(varargin{1})
                    case 'SMASH.ImageAnalysis.Image'
                        object.Measurement=varargin{1};
                        object=create(object);                                
                        object=rotate(object,'auto');
                    case 'SMASH.ImageAnalysis.StepWedge'
                        object=varargin{1};
                    otherwise
                        error('ERROR: unable to contruct object from this input');
                end
            else
                error('ERROR: unable to contruct object from this input');
            end           
        end
    end
    %% controlled methods
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);        
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end 
    methods (Hidden=true)        
        varargout=locate(varargin);
        varargout=generate(varargin);
    end
    %% setters
    methods
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.ImageAnalysis.Image'),...
                'ERROR: invalid Measurement value');
            object.Measurement=value;
        end
    end
end