% This class manages region of interest slices.  Slices are
% defined by an independent direction ('x' or 'y'), with monotonically
% increasing coordinates along this direction. At each location, the slice
% extends infinitely in the dependent direction. 
%    object=Curve(); % default mode is 'x'
%    object=Curve('x'); % same as above
%    obejct=Curve('y'); % x(y)
% Slice points are automatically sorted and purged of any repeated
% independent coordinates.
%
%<a href="matlab:SMASH.System.showExample('SlicesExample','+SMASH/+ROI/@Slices')">Slices selection example</a>%
%
% See also SMASH.ROI
%

% created February 28, 2018 by Justin Brown (Sandia National Laboratories)
% - Modified from Points class

classdef Slices < SMASH.ROI.Generic    
    %%
    properties (SetAccess=protected)
        Mode  % Independent direction mode ('x' or 'y')
    end   
    properties (SetAccess=protected, Hidden=true)
        ValidModes = {'x','y'}            
    end
    %%
    methods (Hidden=true)
        function object=Slices(mode)
            % call constructor
            object=object@SMASH.ROI.Generic();                 
            % manage input
            if (nargin < 1) || isempty(mode)
                mode='x';
            end            
            assert(ischar(mode),'ERROR: invalid mode');
            mode=lower(mode);
            switch mode
                case { 'x','y'}
                    object.Mode=mode;   
                otherwise
                    error('ERROR: invalid mode');
            end        
            % default settings
            object.Name='Slices of interest';
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
            object=packtools.call('Slices');
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