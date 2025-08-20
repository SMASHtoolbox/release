% This class provides simple database capabilities.  The database is
% conceptually equivalent to a structure array, with each element
% representing a distinct record.  Records share a common set of field
% names but may have distinct values (consistent data types required). Flat
% (non-recursive) databases are required, so data values are restricted to
% one-dimensional character arrays, logical arrays, and numeric arrays;
% higher-dimensional arrays are automatically convereted to 1D.
%
% To create a database object, type:
%    >> object=SimpleDatabase(filename);
% where "filename" is the name of a text file.  Read/write access to the
% file is provided by methods.
%    >> write(object,data);
%    >> data=read(object);
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef SimpleDatabase
    %%
    properties 
        Filename % Database file name
        NumericFormat % Print format for numerical values
    end
    methods (Hidden=true)
        function object=SimpleDatabase(filename)
            if (nargin<1) || isempty(filename)
                [filename,pathname]=uiputfile('*.*','Select database file');
                assert(ischar(filename),'ERROR: no database file specified');
                filename=fullfile(pathname,filename);
            end
            object.Filename=filename;
            object.NumericFormat='%g ';
        end
    end
end