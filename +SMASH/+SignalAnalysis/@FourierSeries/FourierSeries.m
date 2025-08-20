% UNDER CONSTRUCTION
% object=FourierSeries(x,y,order);

classdef FourierSeries
    properties (SetAccess=protected)
        XData        
        YData              
        Order = 1
        Coefficients
        Grid
        Fit
    end
    properties
        GridPoints=100;
    end
    methods (Hidden=true)
        function object=FourierSeries(varargin)
            object=update(object,varargin{:});
        end
    end
    
end