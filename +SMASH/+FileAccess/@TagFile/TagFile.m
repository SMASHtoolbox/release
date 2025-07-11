% This class manages text files organized in tagged blocks.  Tags are
% character strings on a line that begins and ends with square brackets
% (igorning extraneous white space).  For example:
%    [block A]
%    This is the first block.
%    It can span multiple lines.
%
%    [block B]
%    This is an entirely diffent block
%
% Tags are case sensitive, must be unique within a file, cannot contain
% square brackes, and may not begin with a dash. Blocks begin at the first
% non-empty line after the tag and run through the last non-empty line
% before the next tag (or file termination).
%
% See also SMASH.FileAccess
%

%
% created October 16, 2018 by Daniel Dolan (Sandia National Laboratories)
%
classdef TagFile < SMASH.FileAccess.File
     %%
    properties (Hidden=true)
        FilterSpec={...
            '*.dat;*.DAT;*.txt;*.TXT;','Common text files';...
            '*.*','All files';}
    end
    %%
    methods (Hidden=true)
        function object=TagFile(filename)
            object=object@SMASH.FileAccess.File();
            if nargin < 1
                filename='';
            end
            object=select(object,filename);
        end
    end        
end