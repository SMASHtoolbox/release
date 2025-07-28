% The class manages rectangular regions of interest.  Three rectangular
% modes are supported.
%    -'x' defines a finite region in the x-direction only
%    -'y' defines a finite region in the y-direction only
%    -'xy' allows finite regions in both directions
% The default mode is 'xy', but any mode can be selected at object
% creation.
%    object=Rectangle(); % use default mode
%    object=Rectangle(mode); % explicitly specify mode
%
%<a href="matlab:SMASH.System.showExample('RectangleExample','+SMASH/+ROI/@Rectangle')">Rectangle selection example</a>
%
% See also SMASH.ROI
%

%
% created September 28, 2017 by Daniel Dolan (Sandia National Laboratories)
%
classdef Rectangle < SMASH.ROI.Generic
    %%
    properties (SetAccess=protected)      
        Mode = 'xy' % Rectangle mode ('xy' 'x' 'y')
    end  
    properties (SetAccess=protected, Hidden=true)
        ValidModes = {'xy' 'x' 'y'}
    end
    %%
    methods (Hidden=true)
        function object=Rectangle(mode)
            % call constructor
            object=object@SMASH.ROI.Generic();
            % manage input
            if (nargin < 1) || isempty(mode)
                mode='xy';
            end
            assert(ischar(mode),'ERROR: invalid rectangle mode');
            mode=lower(mode);
            switch mode
                case  'xy' 
                    object.Data=[-inf +inf -inf +inf];
                case {'x' 'y'}
                    object.Data=[-inf +inf];                    
                otherwise
                    error('ERROR: invalid rectangle mode');
            end       
            object.Mode=mode;                                
            % default settings
            object.Name='Rectangle of interest';
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
            object=packtools.call('Rectangle');
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end   
        end
    end
end