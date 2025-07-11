% Spreadsheet Spreadsheet interface class
%
% This class provides an interactive interface to spreadsheet files.  
%    object=Spreadsheet(filename);
% If no file name is specified, the user is prompted to select one.
% Microsoft Excel documents (*.xls or *.xlsx) with one or more worksheets
% are supported.  Delimited text files, such as comma-separated values
% (*.csv) are also allowed.
%
% See also SMASH.FileAccess
%

%
% created January 23, 2019 by Daniel Dolan (Sandia National Laboratories)
%
classdef Spreadsheet
    %%
    properties (SetAccess=protected)
        FileName % Short file name
        PathName % File location
        Extension % File extension
        FullName % Full file name
    end
    properties (SetAccess=protected, Dependent=true)
        Sheet % Worksheet names (Excel files only)
    end
    properties
        Width = 80 % Displayed table width (characters)
        Height = 40 % Maximum displayed table height (characters)
    end
    %%
    methods (Hidden=true)
        function object=Spreadsheet(filename)
            % manage input
            if (nargin < 1) || isempty(filename)
                FilterSpec={...
                    '*.xls;*.XLS;*.xlsx;*.XLSX;','Excel files';...
                    '*.csv;*.CSV','Comma delimited files';...
                    '*.*','All files'};
                [filename,pathname]=uigetfile(FilterSpec,...
                    'Select spreadsheet file');
                if isnumeric(filename)
                    error('ERROR: no file selected');
                end
                filename=fullfile(pathname,filename);                                               
            else
                assert(ischar(filename),'ERROR: invalid file name');
                assert(logical(exist(filename,'file')),...
                    'ERROR: spreadsheet file does not exist');                
            end
            % process file name
            start=pwd;
            [pathname,short,ext]=fileparts(filename);
            if isempty(pathname)
                pathname=start;
            end
            try 
                cd(pathname)
                pathname=pwd;
                cd(start);
            catch
                cd(start);
                error('ERROR: invalid file location');
            end               
            object.FileName=[short ext];
            object.PathName=pathname;
            object.Extension=ext;            
            object.FullName=fullfile(pathname,object.FileName);
            % 
        end
    end
    %% getters
    methods
        function value=get.Sheet(object)
            switch lower(object.Extension)
                case {'.xls' '.xlsx'}
                    try
                        [status,sheet]=xlsfinfo(object.FullName);
                    catch
                        error('ERROR: cannot find spreadsheet file');
                    end
                    assert(~isempty(status),'ERROR: cannot read spreadsheet file');
                    value=sheet;
                otherwise
                    value='';
            end
        end
    end
    %% setters
    methods
        function object=set.Width(object,value)
            assert(SMASH.General.testNumber(value,'positive','notzero'),...
                'ERROR: invalid table width');
            object.Width=value;
        end
        function object=set.Height(object,value)
            assert(SMASH.General.testNumber(value,'positive','notzero'),...
                'ERROR: invalid height width');
            object.Height=value;
        end
    end
    
end