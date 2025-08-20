% DIGfile 
%
% Class methods are provided for reading from, writing to, and probing files
% defined in the object.
%
% See also FileAccess

%
classdef DIGfile < SMASH.FileAccess.File
    %%
    properties (Hidden=true)
        FilterSpec={...
            '*.dig;*.DIG','NTS digitizer files';...
            '*.*','All files';};
    end
    %%
    methods (Hidden=true)
        function object=DIGfile(filename)
            object=object@SMASH.FileAccess.File();
            if nargin<1
                filename='';
            end
            object=select(object,filename);
        end
    end
end
