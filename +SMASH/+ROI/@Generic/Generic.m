% This abstract class is for defining region of interest arrays
%
%

%
% created September 22, 2017 by Daniel Dolan (Sandia National Laboratories)
%
classdef Generic
    %%
    properties
        Name = 'Region of interest' % Text label
        Comments = '' % Text comments
    end
    properties(SetAccess=protected, Abstract=true)
       Mode % Mode ROI-specific mode
    end
    properties (SetAccess=protected)
        Data % Data Data table
    end
    properties (Hidden=true)
        GraphicOptions % Graphic options object                
    end
    %%
    methods (Hidden=true)
        function object=Generic()
            %if (nargin == 1) && strcmpi(varargin{1},'empty')
            %    object=remove(object);
            %    return
            %end
            object.GraphicOptions=SMASH.General.GraphicOptions();
        end
    end
    %% defined by subclasses
    methods (Abstract=true)
        varargout=define(varargin)
        varargout=view(varargin)
        varargout=select(varargin)
    end    
    %% setters
    methods
        function object=set.Name(object,value)
            assert(ischar(value),'ERROR: invalid name');
            object.Name=value;
        end
        function object=set.Comments(object,value)
            assert(ischar(value),'ERROR: invalid comments');
            object.Comments=value;
        end
    end      
end