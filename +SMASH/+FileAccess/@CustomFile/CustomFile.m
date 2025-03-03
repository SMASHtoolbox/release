% CustomFile Class for accessing custom text files
%
% Syntax:
%    >> object=CustomFile([filename],[format]);
% Supported formats include:
%    'oceanoptics'      - Ocean Optics spectrometer measurements
%    'optronicslab'     - Optronics Laboratory spectrometer measurements
%    'optronicslabdump' - Optronics Laboratory screen dump
% If no format is specified, the user will be prompted to select one.  No
% automatic associations are performed based on file extension.
%
% See also FileAccess, read
%

%
classdef CustomFile < SMASH.FileAccess.File
    properties (SetAccess=protected)
        Format
    end
    properties (Hidden=true)
        FilterSpec={'*.*','All files';};
    end
    %%
    methods (Hidden=true)
        function object=CustomFile(filename,format)
            object=object@SMASH.FileAccess.File();
            if nargin<1
                filename='';
            end
            if nargin<2
                format='';
            end
            object=select(object,filename,format);
        end
    end
end
