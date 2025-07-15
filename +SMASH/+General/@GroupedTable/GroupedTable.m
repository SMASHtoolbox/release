% GroupedTable Grouped data table
%
% This class creates grouped table objects.  These objects are based on
% numeric data arrays, where each column represents some variable of
% interest. One of these variables can be used separate the other variables
% into meaningful groups.  For example, a three-column array [x y z] can be
%  divided into (x,y) arrays based on distinct z values.
%
% Grouped data tables can be created from a numeric table or table object.
%    object=GroupedTable(data);
% Column labels are pulled from table objects.  Column labels are generated
% automatically for numeric tables or specified manually by a cell array of
% character vectors.
%    object=GroupedTable(data,label);
% Objects can also be defined from a text file (with an arbitrary header)
% with numeric data columns.
%    object=GroupedTable(file);
% At least three data columns are required in all cases.
%
%    <a href="matlab:SMASH.System.showExample('MultipleLines','+SMASH/+General/@GroupedTable')">Multiple line example</a>
%
% See also SMASH.General
%

%
% created March 1, 2018 by Daniel Dolan (Sandia National Laboratories)
% 
classdef GroupedTable
    %%
    properties (Dependent=true)
        Data % Data table (numeric matrix)
        Label % Data label (cell array of character vectors)
    end
    properties (SetAccess=protected, Dependent=true)
        GroupColumn % Group column (integer)
        GroupWidth % Group width (scalar)
    end
    properties (SetAccess=protected, Hidden=true)
        PrivateData
        PrivateLabel = {}
        PrivateGroupColumn
        PrivateGroupWidth 
    end
    properties (SetAccess=protected, Dependent=true)
        Columns % Number of data columns
        Rows % Number of data rows
    end
    %%
    methods (Hidden=true)
        function object=GroupedTable(varargin)
            if nargin == 0 % make an empty table
                return
            end
            if istable(varargin{1})           
                object.Data=varargin{1};
            elseif isnumeric(varargin{1})
                 object.Data=varargin{1};
                 if nargin >= 2
                     object.Label=varargin{2};
                 end
            elseif ischar(varargin{1})
                temp=SMASH.FileAccess.readFile(varargin{1},'column');
                object=packtools.call('GroupedTable',temp.Data);
            end
            object=group(object,1); % Default grouping by first column
        end
        varargout=verifyColumn(varargin)
    end
    %% getters
    methods
        function value=get.Data(object)
            value=object.PrivateData;
        end
        function value=get.Label(object)
            value=object.PrivateLabel;
        end        
        function value=get.GroupColumn(object)
            value=object.PrivateGroupColumn;
        end
        function value=get.GroupWidth(object)
            value=object.PrivateGroupWidth;
        end
        function value=get.Columns(object)
            value=size(object.PrivateData,2);
        end
        function value=get.Rows(object)
            value=size(object.PrivateData,1);
        end
    end
    %% setters
    methods 
        function object=set.Data(object,value)
            if istable(value)
                value=table2array(value);
            end
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid data')            
            object.PrivateData=value;
            assert(object.Columns >= 3,...
                'ERROR: data table must have three or more columns');
            % update labels
            start=numel(object.PrivateLabel)+1;
            for n=start:object.Columns
                object.PrivateLabel{n}=sprintf('Column %d',n);
            end
            % update grouping
            if isempty(object.GroupColumn)
                % do nothing
            elseif (object.GroupColumn > object.Columns)
                object.GroupColumn=[];
                object.GroupWidth=0;
            end
        end
        function object=set.Label(object,value)
            assert(iscellstr(value),...
                'ERROR: data labels must be a cell array of character vectors');
            assert(numel(value) == object.Columns,...
                'ERROR: invalid number of data labels');
            object.PrivateLabel=value;
        end       
    end    
end