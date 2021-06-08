% SFR Sparse frequency reduction class
%
% This class supports sparse frequency reduction, which represents a
% measured signal by a modest time-frequency data set.  SFR objects may be
% created from a data file:
%    object=SFR(file,format,record); % "format" and "record" are optional for some file types
% existing time/signal arrays:
%    object=SFR(time,signal);
% or an existing Signal object;
%    object=SFR(source);
% The static method generateExample creates SFR objects for several
% standard cases: steady frequency; slow and fast chirp; instantaneous
% jump; multiple frequencies; and variable amplitude.
%
% See also SMASH.SignalAnalysis, SMASH.FileAccess.SupportedFormats, Signal
%
classdef SFR < SMASH.Developer.SimpleHandle
    %% processing mode
    properties (Hidden=true)
        Mode='debug'; % Proccessing mode ('debug' or 'standard')
    end
    methods
        function set.Mode(object,value)
            if strcmpi(value,'debug') || strcmpi(value,'standard')
                object.Mode=lower(value);
            else
                error('ERROR: invalid processingm mode');
            end
        end
    end
    %% name
    properties
        Name % Object name (character array)
    end
    methods
        function set.Name(object,value)
            if isstring(value)
                value=char(value);
            end
            assert(ischar(value),'ERROR: invalid object name');
            object.Name=value;
        end
    end    
    %% units
    properties
        % Units Physical units (structure)
        %
        % This property stores physical units associated with time and
        % frequency.  These units are used in plot labels but play no role
        % in the underlying analysis.
        % 
        % See also SFR
        Units=struct('Time','','Frequency','');
    end
    methods
        function set.Units(object,value)
            try
                assert(ischar(value.Time));
                assert(ischar(value.Frequency));
            catch
                error('ERROR: invalid unit setting');
            end
            object.Units=struct(...
                'Time',value.Time,'Frequency',value.Frequency);
        end
    end
    %% measurement
    properties (SetAccess=protected)
        SampleRate    % Measurement sample rate
        % FrequencyBand Frequency band of interest
        %
        % This property defines a static ferquency band of interest for the
        % preview and reduce methods.
        %
        % See also SFR, setFrequencyBand
        FrequencyBand 
    end
    properties (SetAccess=protected, Hidden=true)
        StartTime
    end
    properties (SetAccess=protected, Dependent=true)
        Time   % Measurement time base
    end
    methods
        function value=get.Time(object)
            N=numel(object.Signal);
            value=cast(0:(N-1),'like',object.Signal);            
            value=object.StartTime+value(:)/object.SampleRate;
            value=value(:);
        end
    end
    properties (SetAccess=protected)
        Signal % Measurement signal values
    end
    %% effective amplitude
    properties (SetAccess=protected, Hidden=true)
        PrivateAmplitude
    end
    %% digital window and rise time
    properties (SetAccess=protected)
        Window    % Digital window information (structure)
    end
    properties (SetAccess=protected, Dependent=true)
        MinimumRise % Minimum rise time supported by measurement
        MaximumRise % Maximum rise time supported by measurement
    end
    methods
        function value=get.MinimumRise(object)
            excess=4; % max peak width relative to Nyquist limit
            tau=excess*(2/object.SampleRate);
            value=2*object.Window.Scaling*tau;
        end
        function value=get.MaximumRise(object)
            t=object.Time;
            beta=object.Window.Scaling;
            value=2*beta*abs(t(end)-t(1));
        end
    end
    properties (Dependent=true)
        % RiseTime Estimated 10-90% rise time limit
        %
        % This property defines the estimated 10-90% rise time limit for
        % instantaneous changes.  Setting this property automatically
        % changes the FullTime, FullPoints, and EffectiveTime properties.
        % Values are automatically adjusted to be consistend with the
        % SampleRate property.
        %
        % See also SFR
        RiseTime
    end
    properties (SetAccess=protected, Dependent=true)
        FullTime        % Full analysis time duration
        FullPoints      % Number of points in full analysis duration
        EffectiveTime   % Effective analysis time duration
    end
    properties (SetAccess=protected, Hidden=true)
        PrivateRiseTime = nan
        PrivateFullTime = nan
        PrivateFullPoints = nan
    end
    methods
        function value=get.RiseTime(object)
            value=object.PrivateRiseTime;
        end
        function set.RiseTime(object,value)
            if isempty(value)
                value=max(object.MinimumRise,object.MaximumRise/10);
            else
                assert(testNumber(value),'ERROR: invalid rise time')
            end
            if value < object.MinimumRise
                value=object.MinimumRise;
                warning('Rise time increased to measurement limit');
            elseif value > object.MaximumRise
                value=object.MaximumRise;
                warning('Rise time decreased to measurement limit');
            end
            beta=object.Window.Scaling;
            duration0=value/(2*beta);
            steps=ceil(object.SampleRate*duration0);
            if rem(steps,2) == 1
                steps=steps+1; % enforce even steps, odd points
            end
            object.PrivateFullTime=steps/object.SampleRate;
            object.PrivateFullPoints=steps+1;
            object.PrivateRiseTime=2*beta*object.FullTime;
            object.StepTime=object.RiseTime/5;
            object.PrivateAmplitude=[];
        end
        function value=get.FullTime(object)
            value=object.PrivateFullTime;
        end
        function value=get.FullPoints(object)
            value=object.PrivateFullPoints;
        end
        function value=get.EffectiveTime(object)
            beta=object.Window.Scaling;
            beta0=1/sqrt(12); % boxcar scale factor
            value=beta/beta0*object.FullTime;
        end
    end
    %% transform points
    properties (SetAccess=protected, Dependent=true)
        TransformPoints % Number of points in FFT
    end
    methods
        function value=get.TransformPoints(object)
            value=pow2(nextpow2(object.FullPoints*object.PeakPoints/2));
        end
    end
    properties
        PeakPoints = 20 % Minimum number of points in transform peak
    end
    methods
        function set.PeakPoints(object,value)
            assert(testNumber(value),'ERROR: invalid peak points')
            assert(value >= 3,'ERROR: peak points must be >= 3');
            object.PeakPoints=value;
        end
    end
    %% step time
    properties (Dependent=true)
        StepTime     % Time step between analysis durations
        StepPoints  % Points between each FFT analysis
    end
    properties (SetAccess=private, Hidden=true)
        PrivateStepPoints
    end
    properties (SetAccess=protected, Dependent=true)
        TotalSteps % Total reduction steps
    end
    methods
        function value=get.StepTime(object)
            value=object.StepPoints/object.SampleRate;
        end
        function set.StepTime(object,value)
            assert(testNumber(value),'ERROR: invalid step time');
            object.StepPoints=value*object.SampleRate;
            object.PrivateAmplitude=[];
        end
        function value=get.StepPoints(object)
            value=object.PrivateStepPoints;
        end
        function set.StepPoints(object,value)
            assert(testNumber(value) && (value >= 1),...
                'ERROR: invalid step points');
            value=ceil(value);
            object.PrivateStepPoints=min(value,numel(object.Signal));
            object.PrivateAmplitude=[];
        end
        function value=get.TotalSteps(object)
            points=numel(object.Time);
            stop=object.FullPoints:object.StepPoints:points;
            value=numel(stop);
        end
    end
    %% noise
    properties (SetAccess=protected)
        % Noise Noise content (structure)
        %
        % This *protected* property stores noise information as a
        % structure.  This structure is updated by the estimateNoise
        % method.
        %
        % See also SFR, estimateNoise
        Noise
    end
    %% result storage
    properties (SetAccess=protected)
        Preview     % Reduction preview results (structure array)
        Selection   % Region of interest selection (object array)
        Reduction   % Frequency reduction results (structure array)
    end
    %% colormap
    properties
        % Colormap Plot color map
        %
        % This property controls the colormap used in preview/reduction
        % plotting.  Any three-column RGB array with elements ranging from
        % 0 to 1 can be used; the array must have at least two rows.
        % Standard colormaps can be called by name: 'gray', 'jet', and so
        % forth.  Modified names, such as 'reversegray', invert the
        % colormap function.
        %
        % See also SFR, plot
        Colormap
    end
    methods
        function set.Colormap(object,value)
            if ischar(value) || isstring(value)
                if isstring(value)
                    value=char(value(1));
                end
                invert=false;
                if startsWith(value,'reverse')
                    invert=true;
                    value=value(8:end);
                end
                try
                    value=feval(value);
                catch
                    error('ERROR: unrecognized color map name');
                end
                if invert
                    value=value(end:-1:1,:);
                end
                object.Colormap=value;
                return
            end
            assert(isnumeric(value) && ismatrix(value),...
                'ERROR: invalid color map');
            [rows,columns]=size(value);
            assert(rows > 1,'ERROR: color map must have at least 2 rows');
            if columns == 1
                value=repmat(value,[1 3]);
            else
                assert(columns == 3,'ERROR: color map must have 3 columns');
            end
            temp=value(:);
            assert(all(temp >= 0) && all(temp <= 1),...
                'ERROR: color map values must be >= 0 and <= 1');
            object.Colormap=value;
        end
    end
    %%
    methods (Hidden=true)
        function object=SFR(varargin)
            % manage input
            try
                source=SMASH.SignalAnalysis.Signal(varargin{:});
            catch ME
                throwAsCaller(ME);
            end
            % store measurement
            if ~source.GridUniform || (source.Grid(1) > source.Grid(end))
                source=regrid(source);
            end
            t=source.Grid;
            object.StartTime=t(1);
            object.SampleRate=(numel(t)-1)/abs(t(end)-t(1));
            object.Signal=single(source.Data);
            % generate name
            persistent counter
            if isempty(counter)
                counter=1;
            else
                counter=counter+1;
            end
            object.Name=sprintf('SFR_%d',counter);
            % finish set up
            setWindow(object,'hann');
            setFrequencyBand(object,'full');
            object.Colormap='reverseparula';
        end
        varargout=evaluateWindow(varargin)
        varargout=calibrateWindow(varargin)
        varargout=generateParameter(varargin)
        varargout=process(varargin)
        varargout=getResult(varargin)
        varargout=generatePatches(varargin)
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=generateWindow(varargin)
    end
    %%
    methods (Static=true)
        varargout=generateExample(varargin)
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=calculateFFT(varargin)
        varargout=compareArrays(varargin)
        varargout=identifyContent(varargin)
    end
end