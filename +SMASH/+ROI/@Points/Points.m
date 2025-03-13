% This class manages (x,y) points that define a region of interest.  Four
% modes for managing these points are supported:
%    -'open' means that points are not connected in any way.
%    -'connected' means that adjacent points are connected.
%    -'closed' means that adjacent points are connected as well as the
%    first and last point.
%    -'convex' define a convex hull around the outermost points; point
%    selections inside of the hull are ignored.
% The default mode is 'closed', but other modes can be defined at object
% creation.
%    object=Points(); % use default mode
%    object=Points(mode); % explicitly specify mode
%
%<a href="matlab:SMASH.System.showExample('PointsExample','+SMASH/+ROI/@Points')">Point selection example</a>
%
% See also SMASH.ROI
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
%
classdef Points < SMASH.ROI.Generic    
    %%
    properties (SetAccess=protected)
        Mode  % ROI mode ('open', 'connected', 'closed', or 'convex')
    end   
    properties (SetAccess=protected, Hidden=true)
        ValidModes = {'closed' 'open' 'connected' 'convex'}            
    end
    %%
    methods (Hidden=true)
        function object=Points(mode)
            % call constructor
            object=object@SMASH.ROI.Generic();                 
            % manage input
            if (nargin < 1) || isempty(mode)
                mode='closed';
            end            
            assert(ischar(mode),'ERROR: invalid mode');
            mode=lower(mode);
            switch mode
                case { 'open' 'connected' 'closed' 'convex'}
                    object.Mode=mode;   
                otherwise
                    error('ERROR: invalid mode');
            end        
            % default settings
            object.Name='Points of interest';
            name=properties(object.GraphicOptions);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=object.GraphicOptions.(name{n});
                end
            end           
        end
    end   
    %%
    methods (Static=true,Hidden=true)
        function object=restore(data)
            object=packtools.call('Points');
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end   
        end
    end
    %%   
    methods (Static=true)
        varargout=getpts(varargin)
    end
end