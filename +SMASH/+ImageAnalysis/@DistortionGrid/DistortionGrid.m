% This class is a specialized form of the Image class, with specialized
% capabilities for characterizing and removing geometric distortion.
% Distortion grid objects are usually created from one or more image files.
%    object=DistortionGrid(filename,format,label);
% The inputs "format" and "label" may be optional depending on the type of
% graphic file.  Multiple images of the same format, specified using
% a wild card in the filename, are summed into a common image
%    object=DistortionGrid('*.imd')
% Image data is stored in the Measurement property and can be accessed
% directly.
%    view(object.Measurement); % display distortion image
%    object.Measurement.DataLim='auto'; % change image data limits
% The Measurement property can be modified (as in the second example) but
% must always remain an Image object.
%
%
% See also SMASH.ImageAnalysis, Image
%

%
% created June 22, 2016  by Daniel Dolan (Sandia National Laboratories)
%
classdef DistortionGrid 
    properties
        Measurement % Measured distortion grid (Image object)
    end    
    %%
    properties (SetAccess=protected)        
        IsoPoints = [] % (x,y) table of IsoPoints, NaN separators between groups
        IsoMesh1 = [] % Mesh constructed from IsoPoints (Grid1 values)
        IsoMesh2 = [] % Mesh constructed from IsoPoints (Grid2 values)
        ArcMesh1 = [] % Undistored mesh (Grid1 values)
        ArcMesh2 = [] % Undistored mesh (Grid2 values)
    end
    %%
    methods (Hidden=true)
        function object=DistortionGrid(varargin)
            if nargin==0
                temp=SMASH.ImageAnalysis.Image();
                object=SMASH.ImageAnalysis.DistortionGrid(temp);
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
                    object=SMASH.ImageAnalysis.DistortionGrid(temp);
                catch
                    error('ERROR: unable to construct object from SDA record');
                end
            elseif isobject(varargin{1})
                switch class(varargin{1})
                    case 'SMASH.ImageAnalysis.Image'
                        object.Measurement=varargin{1};
                        object=create(object);                                
                    case 'SMASH.ImageAnalysis.DistortionGrid'
                        object=varargin{1};
                    otherwise
                        error('ERROR: unable to contruct object from this input');
                end
            else
                error('ERROR: unable to contruct object from this input');
            end
        end
    end
    %% 
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    methods (Access=protected, Hidden=true)
        varargout=mesh(varargin)
        varargout=remesh(varargin)
        varargout=blurLocal(varargin)
        varargout=blurGlobal(varargin)
    end
end