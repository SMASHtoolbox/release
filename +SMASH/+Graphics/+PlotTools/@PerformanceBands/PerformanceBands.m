classdef PerformanceBands
    properties (Dependent=true)
        Group 
        Color % Band colors used by view method
    end
    properties (Access=protected, Hidden=true)
        PrivateGroup 
        PrivateColor = lines(7) 
    end
    properties
        Label = 'Performance' % Data label used by view method
        Direction = 'vertical' % Band direction
    end
    %%
    methods (Hidden=true)
        function object=PerformanceBands(varargin)
            
        end
    end
    %% getters
    methods
        function value=get.Group(object)
            value=object.PrivateGroup;
        end
        function value=get.Color(object)
            value=object.PrivateColor;
        end
    end
    %% setters
    methods 
        function object=set.Group(object,value)
            
        end
    end
end