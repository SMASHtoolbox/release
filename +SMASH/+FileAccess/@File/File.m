% This is a basic file access class
classdef File
    properties (SetAccess=protected)
        FileName % Access file name
        PathName % Access file location
        Extension % File extension
    end
    properties (Hidden=true)
        FullName
        DialogTitle='Select file';
    end
    properties (Hidden=true,Abstract=true)        
        FilterSpec
    end
    methods
        function object=File(filename)
            if (nargin>=1)
                object=select(object,filename);
            end            
        end
    end
end