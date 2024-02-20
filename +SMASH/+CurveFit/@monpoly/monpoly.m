classdef monpoly < SMASH.Developer.SimpleHandle   
    %% reference point
    properties
        Reference = [0 0] % [x0 y0]
    end
    methods
        function set.Reference(object,value)
            assert(isnumeric(value) && (numel(value) == 2) && ...
                all(isfinite(value)) && isreal(value),...
                'ERROR: invalid reference point');
            object.Reference=value;
        end
    end    
    %% order and parameters
    properties (SetAccess=protected)
        Order
    end
    properties
        Slope = 1
    end
    methods
        function set.Slope(object,value)
            assert(isnumeric(value) && isscalar(value) ...
                && isfinite(value) && (value ~= 0),...
                'ERROR: invalid slope');
            object.Slope=value;
        end
    end
    properties
        Parameter        
    end
    methods        
        function set.Parameter(object,value)
            if isempty(object.Parameter)
                object.Parameter=value;
                return
            end
            assert(isnumeric(value) && all(isfinite(value)),...
                'ERROR: invalid parameter');           
            assert(all(size(value) == size(object.Parameter)),...
                'ERROR: invalid number of parameters');
            object.Parameter=value;
        end
    end
    %%
    methods (Hidden=true)
        function object=monpoly(order)
            assert(nargin > 0,'ERROR: order must be specified');
            assert(isnumeric(order) && isscalar(order) && (order >= 0),...
                'ERROR: order must be a number >= 0');
            object.Order=ceil(order);
            if object.Order > 0           
                object.Parameter=zeros(2,object.Order);
            end
        end
    end

end