% ColumnFile Class for accessing text information arranged in columns
%
%    >> object=ColumnFile([filename]);
%
% Column information is assumed to begin at the first line containing at
% least one number and no text; column delimeters (commas, spaces, and
% ampersands by default) are ignored.  Everything above this first line is
% treated as a text header.  Custom delimeters and a minimum
% number of columns can be specified as options to fine tune the transition
% from header to columns.
%
% See also FileAccess, probe, read, select, write
%

%
classdef ColumnFile < SMASH.FileAccess.File
    properties (Hidden=true)
        FilterSpec={...
            '*.dat;*.DAT;*.txt;*.TXT;*.csv;*.CSV;*.out;*.OUT','Common text files';...
            '*.*','All files';};
    end
    methods (Hidden=true)
        function object=ColumnFile(filename)           
            object=object@SMASH.FileAccess.File();
            if nargin<1
                filename='';
            end
            object=select(object,filename);
            switch lower(object.Extension)
                case {'.xls' '.xlsx'}
                    message={};
                    message{end+1}='ERROR: this format cannot be used to read binary files';
                    message{end+1}='       Use MATLAB''s "xlsread" function to access spreadsheet files';
                    error('%s\n',message{:});
            end
        end
    end    
end