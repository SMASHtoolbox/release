%
%    object=InfiniteLines('XData',x);
%    object=InfiniteLines('YData',y);
%
%    object=InfiniteLines('XData',x,'ZData',z);
%    object=InfiniteLines('YData',y,'ZData',z);

classdef InfiniteLines < matlab.mixin.SetGet
    properties (SetAccess=protected)        
        Handle
        NumberLines
    end    
    properties (Dependent=true)
        XData
        YData
        ZData
    end
    %%
    methods (Hidden=true)
        function object=InfiniteLines(vararargin)
            % manage input
        end
        function delete(object)
            
        end
    end
end