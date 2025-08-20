% UNDER CONSTRUCTION
classdef SinusoidFit < handle
    %%
    properties (SetAccess=protected)
        Source % Source data (Signal object)
        Duration % Source duration (real number)
        % Spectrum Complex frequency spectrum
        % This property stores the full and residual frequency spectrum for
        % the source data.  Complex-valued information is stored as a
        % SignalGroup object.
        Spectrum        
        NumberSinusoids = 0 % Number of defined sinusoids (integer)
        % Parameter Sinusoid parameters
        % This property stores sinusoid parameters in a three-column array.
        % The first column is sinusoid frequency, the second column is
        % amplitude, and the third column is phase (in radians).
        Parameter = nan(0,3) 
    end
    %% optimization control
    properties
        Optimization = optimset() % Optimization options (structure)
    end
    methods
        function set.Optimization(object,value)
            try
                value=optimset(value);
            catch ME
                throwAsCaller(ME);
            end
            object.Optimization=value;
        end
    end
    %% result
    properties (SetAccess=protected, Dependent=true)
        Result % Time-domain fit 
    end
    methods
        function value=get.Result(object) 
            t=object.Source.Grid;
            s=zeros(size(t));  
            for n=1:object.NumberSinusoids
                param=object.Parameter(n,:);          
                theta=2*pi*param(1)*t;
                phi=param(3);
                s=s+param(2)*cos(theta+phi);
            end
            value=reset(object.Source,[],s);
            value.GraphicOptions.LineColor='r';
        end
    end
    %%
    methods (Hidden=true)
        function object=SinusoidFit(varargin)
            if nargin == 0
                return
            elseif isa(varargin{1},'SMASH.SignalAnalysis.Signal')
                object.Source=varargin{1};
            else
                try
                    object.Source=SMASH.SignalAnalysis.Signal(varargin{:});
                catch ME
                    throwAsCaller(ME);
                end
            end
            if ~object.Source.GridUniform
                object.Source=regrid(object.Source);
            end
            t=object.Source.Grid;
            object.Duration=abs(t(end)-t(1));
            generate(object);
            add(object);
        end
    end
    %%
    methods (Access=protected, Hidden=true)
        varargout=scaleBasis(varargin)
    end
    %% hide advanced methods from casual users
    methods (Hidden=true)
        varargout=addlistener(varargin)
        varargout=eq(varargin)
        varargout=findobj(varargin)
        varargout=findprop(varargin)
        varargout=ge(varargin)
        varargout=gt(varargin)
        varargout=le(varargin)
        varargout=listener(varargin)
        varargout=lt(varargin)
        varargout=ne(varargin)
        varargout=notify(varargin)
    end
end