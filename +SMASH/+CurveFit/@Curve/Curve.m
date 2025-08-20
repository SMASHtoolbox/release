% This class describes the relationships between independent variable x and
% dependent variable y as a summation of basis functions f(p,x).
%     y(x) = B1*f1(p1,x) + B2*f2(p2,x) + ...
% Each basis function has a set of internal parameters (p1, p2, etc.) and
% an external scaling factor (B1, B2, etc.).  Given a (x,y) data set, the
% internal parameters are determined via iterative optimization.  External
% parameters are determined with non-iterative, linear least=squares method
% or left fixed.
%
% Curve objects are created with a data table.
%     object=Curve(data);
% Data tables can have two [x y] or three columns [x y dy].  Tables can
% also be generated from a class object having Grid/Data properties, such
% as the Signal class (SMASH.SignalAnalysis package).
%
% Basis functions in the object are controlled with the add, edit, and
% remove methods.  The summarize and evaluate methods describe the current
% object state.  Parameter optimization is provided with the fit method.
%
% See also SMASH.CurveFit, makeBackground, makePeak, makeStep
%

%
% created November 30, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised April 16, 2018 by Daniel Dolan
%
classdef Curve
    %% properties   
    properties (SetAccess=protected)
        DataTable % Data table (2-3 columns)
        EvaluationGrid % Fit evaluation grid (numeric array)
    end
    properties (SetAccess=protected)
        Weight
    end
    properties
        GridLabel = 'x' % Grid label (character array)
        DataLabel = 'y' % Data label (character array)
    end
    properties (SetAccess=protected)
        Basis = {} % Basis functions (cell array of N handles)
        Parameter = {} % Basis function parameters (cell array of 1xN numeric arrays)
        Bound = {} % Variable bounds (cell array of 2xN numeric arrays)
        Scale = {} % Basis scale factors (cell array of N numeric values)
        FixScale = {} % Fixed scaling factor settings (cell array of N logical values)
    end
    properties (Access=protected, Hidden=true)
        FitComplete = false % Indicates complete fit (logical)
    end
    properties (SetAccess=protected, Hidden=true)
        AdjustableParameters
    end
    %properties (SetAccess=protected)
    %    FitTable = [] % table of parmameter values from optimization
    %end
    %% methods
    methods (Hidden=true)
        function object=Curve(varargin)
            try
                object=reset(object,varargin{:});
            catch ME
                throwAsCaller(ME);
            end                      
        end
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% setters
    methods
        function object=set.GridLabel(object,value)
            assert(ischar(value) || isstring(value),'ERROR: invalid grid label');
            object.GridLabel=value;
        end
        function object=set.DataLabel(object,value)
            assert(ischar(value) || isstring(value),'ERROR: invalid data label');
            object.DataLabel=value;
        end
    end
end