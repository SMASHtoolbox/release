% UNDER construction
%
% Pulse train class
%
% This class describes and generates pulsed train signals.  These trains
% are defined on a uniformly spaced grid, which can be specified
% explicitly:
%    object=PulseTrain(x);
% or from a Signal object source.
%    object=PulseTrain(source);
%
% See also SMASH.SignalAnalysis
%


classdef PulseTrain
    %% source grid
    properties (Dependent=true)
        Grid % Signal grid
    end
    properties (SetAccess=protected, Hidden=true)
        Source
    end
    methods
        function value=get.Grid(object)
            value=object.Source.Grid;
        end
        function object=set.Grid(object,value) 
            assert(isnumeric(value),'ERROR: invalid signal grid');
            value=unique(value);
            try
                object.Source=reset(object.Source,value,value);
            catch
                error('ERROR: invalid signal grid');
            end
            object.Source=regrid(object.Source);
        end
    end
    %% horizontal shift
    properties
        Shift = 0 % Horizontal shift
    end
    methods
        function object=set.Shift(object,value)
            assert(SMASH.General.testNumber(value),'ERROR: invalid shift');
            object.Shift=value;
        end
    end    
    %% pulse parameters
    properties (Dependent=true)
        Rise % Pulse rise time
        Hold % Pulse hold time
        Fall % Pulse fall time
        Period % Pulse spacing 
        % enforce symmetry?
    end
    methods % getters
        function value=get.Rise(object)
            value=object.Parameter(1);
        end
        function value=get.Hold(object)
            value=object.Parameter(2);
        end
        function value=get.Fall(object)
            value=object.Parameter(3);
        end
        function value=get.Period(object)
            value=object.Parameter(4);
        end
    end
    methods % setters        
        function object=set.Rise(object,value)
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid rise time');                        
            object.Parameter=adjustParameter(object.Parameter,value,1);
        end
        function object=set.Hold(object,value)
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid hold time');
            object.Parameter=adjustParameter(object.Parameter,value,2);
        end
        function object=set.Fall(object,value)
            assert(SMASH.General.testNumber(value,'positive'),...
                'ERROR: invalid fall time');
            object.Parameter=adjustParameter(object.Parameter,value,3);
        end
        function object=set.Period(object,value)
            assert(SMASH.General.testNumber(value,'positive','notzero'),...
                'ERROR: invalid period');
            object.Parameter=adjustParameter(object.Parameter,value,4);
        end
    end        
    properties 
        Baseline = 0 % Signal baseline
        Amplitude = 1 % Signal amplitude
    end
    methods % setters
        function object=set.Baseline(object,value)
            assert(SMASH.General.testNumber(value),'ERROR: invalid baseline');
            object.Baseline=value;
        end
        function object=set.Amplitude(object,value)
            assert(SMASH.General.testNumber(value),'ERROR: invalid amplitude');
            object.Amplitude=value;
        end
    end
    properties (SetAccess=protected, Hidden=true)
        Parameter
    end
    %% shape function
    properties
        ShapeFcn = [] % Pulse shape function
    end
    methods
        function object=set.ShapeFcn(object,value)
            if isempty(value) || isa(value,'function_handle')
                object.ShapeFcn=value;
            else
                error('ERROR: invalid shape function');
            end
        end
    end
    %% 
    properties (SetAccess=protected, Dependent=true)
        Output % Pulse output
    end
    methods
        function value=get.Output(object)
            value=generate(object);
        end
    end
    %% constructor
    methods (Hidden=true)
        function object=PulseTrain(x)
            % manage input
            if (nargin < 1) || isempty(x)
                x=linspace(0,1,1000);               
            end
            try
                object.Source=SMASH.SignalAnalysis.Signal(x,nan(size(x)));
            catch ME
                throwAsCaller(ME);
            end
            % set up parameters
            period=object.Grid(end)-object.Grid(1);
            period=period/2;
            object.Parameter=[0 period/2 0 period];
        end        
        varargout=generate(varargin)
    end
end
%%
function param=adjustParameter(param,value,index)

width=sum(param(1:3));
param(index)=value;
if (index == 4) && (width > value)
    param(1:3)=param(1:3)/width*value;
else
    param(4)=max(param(4),width);
end

end