% This class creates multiple-image objects on common Grid1 and Grid2 bases.  These
% object are similar to Image objects, but the "Data" property is a
% three-dimensional array.  Each 2-D plane of this array represents the data for
% a particular Image in the group.  Many (but not all) Image methods can
% be applied to ImageGroup objects.
%
% The most direct way to create a ImageGroup object is to pass numerical
% information directly.
%    >> object=ImageGroup(Grid1,Grid2,Data);
% Information can also be imported from a data file.
%    >> object=ImageGroup(filename,[format],[record]);
% The inputs "format" and "record" may be optional depending on the file's
% format and contents.  If the file name contains a wild card ('*.sda')
% that matches more than one file, the object is contructed from the sum of
% the individual files (consistent size required).
%
% See also SMASH.ImageAnalysis, Image
%
% created December 16, 2015 by Tommy Ao (Sandia National Laboratories)
% modified January 6, 2016 by Sean Grant (Sandia National Laboratories)

classdef ImageGroup < SMASH.ImageAnalysis.Image
    %%
    properties (SetAccess=?SMASH.General.DataClass)
        NumberImages = 0 % Number of Images
    end
    properties
        Legend={};
    end
    %% hidden methods
    methods (Hidden=true)
        function object=ImageGroup(varargin)
            object=object@SMASH.ImageAnalysis.Image(varargin{:}); % call superclass constructor
        end
    end    
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% protected methods
     methods (Access=protected,Hidden=true)
        varargout=showSingle(varargin);
        varargout=showMosaic(varargin);
        varargout=showSnapshot(varargin);
        varargout=showFullColor(varargin);
    end
    methods (Access=protected,Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    
    %% set methods
    methods
        function object=set.Legend(object,value)
            assert(iscell(value),'ERROR: invalid Legend');
                object.Legend=value;
        end
    end

    %% static methods
    methods (Static = true)
        varargout = importGOI(varargin);
    end
       
    
end