classdef Session < handle
    %%
    properties (SetAccess=protected)
        Image % Image data (grayscale or RGB array)
        ColorMap % Color map
        ImageFile % Image file
        ParameterMatrix % Transformation parameter matrix (3x2)
    end
    properties
        LogScaling='none'; % Logarithmic scaling ('none', 'horizontal', 'vertical', or 'both')
        ReferenceTable % Reference table: [m n x y]
        DataTable % Data table: [m n x y]
    end
    %%
    methods (Hidden=true)
        function object=Session(varargin)
            if nargin > 0
                loadImage(object,varargin);
            end
        end
    end
    %%
    methods (Static=true)
        varargout=generateExamples(varargin)
    end
    methods (Static=true, Hidden=true)
        function object=restore(data)
            object=datninja.Session();
            name=fieldnames(data);
            for k=1:numel(name)
                try
                    object.(name{k})=data.(name{k});
                catch
                end                
            end
        end
    end
    %% setters
    methods
        function set.LogScaling(object,value)
            assert(ischar(value),'ERROR: invalid log scaling');
            switch lower(value)
                case {'none' 'horizontal' 'vertical' 'both'}
                    object.LogScaling=lower(value);
                otherwise
                    error('ERROR: %s in not a valid type of log scaling');
            end
        end
        function set.ReferenceTable(object,value)
            if isempty(value)
                object.ReferenceTable=nan(0,4);
                return
            end
            assert(isnumeric(value) && ismatrix(value) && (size(value,2) == 4),...
                'ERROR: invalid reference table');
            object.ReferenceTable=value;
        end
        function set.DataTable(object,value)
            if isempty(value)
                object.DataTable=nan(0,4);
                return
            end
            assert(isnumeric(value) && ismatrix(value) && (size(value,2) == 4),...
                'ERROR: invalid reference table');
            object.DataTable=value;
        end
    end
end
