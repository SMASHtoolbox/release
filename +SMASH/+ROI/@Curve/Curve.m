% This class manages region of interest curves.  Curves are
% defined by an independent direction ('x' or 'y'), with monotonically
% increasing coordinates along this direction.  Dependent values at each
% coordinate location define a single-valued function of y(x) or x(y).
%    object=Curve(); % default mode is 'x'
%    object=Curve('x'); % same as above, y(x)
%    obejct=Curve('y'); % x(y)
% Curve points are automatically sorted and purged of any repeated
% independent coordinates.
%
% Each curve point has an associated width value.  For 'x' mode,  the width
% defines the local region of interest above and below the curve; for 'y'
% move, the width defines regions left and right of the curve.
%
%<a href="matlab:SMASH.System.showExample('CurveExample','+SMASH/+ROI/@Curve')">Curve selection example</a>
%
%
% See also SMASH.ROI
%

%
% created October 3, 2017 by Daniel Dolan (Sandia National Laboratories)
%
classdef Curve < SMASH.ROI.Generic
    properties (SetAccess=protected)
        Mode  % Independent direction mode ('x' or 'y')
    end
    properties
        DefaultWidth % Default region width
    end
    properties (SetAccess=protected, Hidden=true)
        ValidModes = {'x' 'y'}
    end
    methods (Hidden=true)
        function object=Curve(mode)
            % call constructor
            object=object@SMASH.ROI.Generic();
            % manage input
            if (nargin < 1) || isempty(mode)
                mode='x';
            end
            assert(ischar(mode),'ERROR: invalid mode');
            mode=lower(mode);
            switch mode
                case {'x' 'y'}
                    object.Mode=mode;
                otherwise
                    error('ERROR: invalid mode');
            end
            % default settings
            object.Name='Curve of interest';
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
            object=packtools.call('Curve');
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end
        end
    end
    %%
    methods
        function object=set.DefaultWidth(object,value)
            if ~isfinite(value) % weird error that sometimes crops up
                value = 100;
            end
            assert(isnumeric(value) && isscalar(value)...
                && isfinite(value),'ERROR: invalid default width');
            value=abs(value);
            assert(value > 0,'ERROR; default width cannot be zero');
            object.DefaultWidth=value;
        end        
    end
end