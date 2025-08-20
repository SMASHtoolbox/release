% This class manages text files where parameters are stored in named
% blocks.  For example:
%    begin{Experiment}
%       Temperature = 300 % K
%       Pressure = 1 % atm
%    end
% defines a parameter set named "Experiment" with numeric parameters
% "Temperature" and "Pressure".  Multiple blocks can be defined in a
% parameter file, and each block can be assigned to its own (case
% sensitive) parameter set. Repeated names define a parameter set array.
%
% Parameter definitions are "name = value" statements that follow MATLAB
% conventions.
%    -The parameter name must be a sequence letters, numbers, and
%    underscores (up to 63 characters long).  The first character must be a
%    letter, and the name cannot be a MATLAB keyword.  Parameter names are
%    case sensitive.
%    -The equal sign is required; space before and after this character is
%    optional.
%    -Parameter values numeric scalars/arrays, character arrays, or cell
%    arrays.  Arithmetic expressions are permitted.
%    -Definitions can span multiple lines by using ellipsis (...)
% Percent signs indicate comments that are ignored when a parameter file is
% read.  Comments can be placed inside or outside parameter set blocks.
%
% Parameter file objects are created by specifying a text file name.
%    object=ParameterFile(filename);
% New parameter files should be explicitly named.  If no name is specified,
% the user is prompted to select an existing file.
%
% See also SMASH.FileAccess
%

%
% created May 10, 2018 by Daniel Dolan (Sandia National Laboratories)
%
classdef ParameterFile < SMASH.FileAccess.File
    %%
    properties (Hidden=true)
        FilterSpec={...
            '*.dat;*.DAT;*.txt;*.TXT;','Common text files';...
            '*.*','All files';};
    end
    %%
    methods (Hidden=true)
        function object=ParameterFile(filename)
            object=object@SMASH.FileAccess.File();
            if nargin<1
                filename='';
            end
            object=select(object,filename);
        end
    end
    
end