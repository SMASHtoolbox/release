% RedundantSignal Redundant signal class
%
% This class manages redundant signals  derived from a common source
% signal. This mapping:
%    r_k(t) = A_k s(t-D_k) + B_k
% depends on grid shifting D_k, data scaling A_k, and data shifting B_k.
% Measured signals r_k(t) may be clipped at limiting values of a recording
% system, while the source signal s(t) does not have these restrictions.
%
% Recorded signal data is specified at object creation.  This can be done
% with a SignalGroup object:
%    object=RedundantSignal(data);
% or several Signal objects.
%    object=RedundantSignal(data1,data2,...);
%
% See also SMASH.SignalAnalysis, SMASH.SignalAnalysis.SignalGroup,
% SMASH.SignalAnalysis.Signal
%

%
% created February 1, 2019 by Daniel Dolan (Sandia National Laboratories)
%
classdef RedundantSignal
    %% measured signals
    properties (SetAccess=protected)
        % Measured signals
        %
        % Measured signals are stored as a SignalGroup object.  The
        % property is defined at object creation and can be modified with
        % the reset method.
        %
        % See also reset, SMASH.SignalAnalysis.SignalGroup
        Measurement
    end
    properties (SetAccess=protected, Dependent=true)
        NumberSignals % Number of measured signals (integer)
    end
    methods
        function value=get.NumberSignals(object)
            if isempty(object.Measurement)
                value=0;
            else
                value=object.Measurement.NumberSignals;
            end
        end
    end
    %% measurement parameters
    properties (Dependent=true)
        % Parameter Transformation parameter array
        % 
        % Measured signals are transformed versions of the source.  The
        % parameters for this transformation are grid shift, data scale,
        % and data shift.  A three-column numeric array stores these
        % parameters in the above order.  Each row in the array pertains to
        % a specific measurement.
        %
        % See also calibrateSinusoid, weld
        Parameter
    end
    properties (Access=protected, Hidden=true)
        PrivateParameter
    end
    methods
        function value=get.Parameter(object)
            value=object.PrivateParameter;
        end
        function object=set.Parameter(object,value)
            if isempty(object.PrivateParameter) || isempty(value)
                object.PrivateParameter=value;
                return
            end
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid parameter array');
            assert((size(value,2) == 3),...
                'ERROR: parameter array must have 3 columns');
            if size(value,1) == 1
                value=repmat(value,[size(object.Parameter,1) 1]);
            else
                assert(size(value,1) == size(object.Parameter,1),...
                    'ERROR: invalid parameter array')
            end            
            object.PrivateParameter=value;
            if strcmp(object.Status,'complete')
                object.Status='obsolete';
            end
        end
    end
    %% measurement ranges
    properties
        % Range Measured signal ranges
        %
        % Measured signals may be clipped at a minimum and/or maximum
        % value.  This two-column array [min max] defines those limits;
        % each row pertains to one measurement.  Infinite values are
        % permitted for measurements that are not clipped.
        Range 
    end
    methods
        function object=set.Range(object,value)
            if isempty(object.Range) || isempty(value)
                object.Range=value;
                return
            end
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid range array');
            assert((size(value,2) == 2),'ERROR: range array must have 2 columns');
            M=size(object.Range,1);
            if size(value,1) == 1
                value=repmat(value,[M 1]);
            else
             assert(size(value,1) == M,'ERROR: invalid range array size');
            end
            object.Range=sort(value,2);
            assert(all(diff(object.Range,[],2) > 0),...
                'ERROR: range min/max must be distinct');
        end       
    end
    %% measurement noise
    properties
        % NoiseRatio Measurement noise ratio
        %
        % This property is an array of characteristic noise ratios for the
        % measurements.  These RMS values (positive, non-zero) are used for
        % relative weighting in the weld method.
        NoiseRatio
    end
    methods
        function object=set.NoiseRatio(object,value)
            if isempty(object.NoiseRatio) || isempty(value)
                object.NoiseRatio=value;
                return
            end
            assert(isnumeric(value) && all(value > 0),...
                'ERROR: invalid noise level values');
            M=numel(object.NoiseRatio);
            if isscalar(value)
                value=repmat(value,[M 1]);
            else
                assert(numel(value) == M,...
                    'ERROR: invalid number of noise level values');
                value=value(:);
            end
            object.NoiseRatio=value;
        end
    end
    %% source properties
    properties (SetAccess=protected)
        % Status Source/Weight status
        %
        % This property indicates the status of the source signal and its
        % associated weights.  The value starts at 'incomplete' until the
        % calculate method is called.  Modifying the Parameter property or
        % resetting the measured signals changes the status from 'complete'
        % to 'obsolete'.
        Status = 'incomplete'
        % Source Source signal
        %
        % This property stores the source (Signal object) from the
        % calculate method.
        Source 
        % Weight Measurement weights
        %
        % This property stores the measurement weights (SignalGroup object)
        % from the calculate method.
        Weight % Measurement weighting (object)
    end
    %% labels
    properties (Dependent=true)
        GridLabel
        DataLabel
    end
    methods
        function value=get.GridLabel(object)
            value=object.Measurement.GridLabel;
        end
        function value=get.DataLabel(object)
            value=cell(1,3);
            value{1}=object.Measurement.DataLabel;
            try
                value{2}=object.Weight.DataLabel;
                value{3}=object.Source.DataLabel;
            catch
            end
        end
        function object=set.GridLabel(object,value)
            assert(ischar(value),'ERROR: invalid grid label');
            object.Measurement.GridLabel=value;
            if ~isempty(object.Source)
                object.Weight.GridLabel=value;
                object.Source.GridLabel=value;
            end
        end
        function object=set.DataLabel(object,value)
            assert(iscellstr(value) && (numel(value) == 3),...
                'ERROR: invalid data label');
            object.Measurement.DataLabel=value{1};
            if ~isempty(object.Source)
                object.Weight.DataLabel=value{2};
                object.Source.DataLabel=value{3};
            end
        end
    end
    %% constructor
    methods (Hidden=true)
        function object=RedundantSignal(varargin)    
            if nargin == 0
                return
            end
            message{1}='ERROR: the RedundantSignal class does not support object arrays';
            message{2}='       Use a cell array of objects instead';
            assert(isscalar(object),'%s\n',message{:});
            if (nargin == 1) && isa(varargin{1},'SMASH.SignalAnalysis.SignalGroup')
                source=varargin{1};
            elseif isa(varargin{1},'SMASH.SignalAnalysis.Signal')
                source=SMASH.SignalAnalysis.SignalGroup(varargin{:});
            else
                error('ERROR: invalid input');
            end
            object=reset(object,source);
        end
    end
    %%
    methods (Static=true)
        varargout=generate(varargin)
        varargout=restore(varargin)
    end
end