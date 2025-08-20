% PFFfile Class for managing access to Portable File Format files
%
% PFF is a binary file type developed at Sandia National Laboratories.
% These files contain one or more datasets organized in one of the
% following formats.
%     1.  Uniform 3D floating point data (PFTUF3)
%     2.  Uniform 1D floating point data (PFTUF1)
%     3.  Non-uniform 3D floating point data (PFTNF3)
%     4.  Non-uniform 3D vector floating point data (PFTNV3)
%     5.  Multi-dimensional vertex data with attributes (PFTVTX)
%     6.  Integer/float list data (PFTIFL)
%     7.  Multi-dimensional vectors on a multi-dimensional space (PFTNGD)
%     8.  Non-uniform 3D grid data (PFTNG3)
%     9.  Non-uniform 3D integer data (PFTNI3)
% Several formats support multiple data blocks within a dataset.
%
% This class provides methods for probing and reading from PFF files.  It
% is intended for advanced users with some knowledge of how the PFF file
% was created.  Similar types of information may be found in different
% formats, so user oversight may be needed to interpret files correctly.
% Specialized classes (such as Signal and Image) in the SMASH toolbox
% provide easier access to PFF files.
%
% Syntax:
%    >> object=PFFfile([filename]);
%
% See also FileAccess, probe, read, select
%

%
classdef PFFfile < SMASH.FileAccess.File
properties (Hidden=true)
        FilterSpec={...
            '*.pff;*.PFF','Portable File Format files';...
            '*.*','All files';};
    end
    methods (Hidden=true)
        function object=PFFfile(filename)
            object=object@SMASH.FileAccess.File();
            if nargin<1
                filename='';
            end            
            object=select(object,filename);  
        end
    end
end
