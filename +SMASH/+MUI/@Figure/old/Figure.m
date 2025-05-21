classdef Figure
    properties
        GraphicHandle
    end
    methods
        function object=Figure(varargin)
            object.GraphicHandle=figure(varargin{:});
        end
        function delete(object)
            if ishandle(object.GraphicHandle)
                delete(object.GraphicHandle);
            end
        end
    end
    
end