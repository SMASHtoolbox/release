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
    properties
        % LoopMode Loop processing mode
        %
        % This property controls how expensive loop calculations are
        % performed.  Valid modes include 'serial' and 'parallel'.  The
        % latter distributes calculations across processors when the
        % Parallel Computing Toolbox is available *and* there is an exiting
        % worker pool.
        %
        % See also SFR
        LoopMode='serial';
    end
    methods
        function set.LoopMode(object,value)
            if strcmpi(value,'serial')
                object.ProcessingMode='serial';
            elseif strcmpi(value,'parallel')
                try
                    pool=gcp('nocreate');
                catch
                    error('ERROR: system does not support parallel loops');                   
                end
                assert(~isempty(pool),...
                    'ERROR: parallel loops require a worker pool');
                object.ProcessingMode='parallel';
            else
                error('ERROR: loop mode must be ''serial'' or ''parallel''');
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
    %% digital window and associated time scales
    properties (SetAccess=protected)
        Window    % Digital window information (structure)
    end    
    properties (SetAccess=public)
        RiseTime
        StepTime
        TotalSteps
    end   
    %% transform points
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
    properties
        NegativeFrequencies = 'off' % Show negative frequencies ('on' or 'off')
    end    
    methods
        function set.NegativeFrequencies(object,value)
           if strcmpi(value,'on') || strcmpi(value,'off')
               object.NegativeFrequencies=lower(value);
           else
               error('ERROR: negative frequencies must be ''on'' or ''off''');
           end
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
            setNoise(object);
            object.Colormap='reverseparula';
        end
        varargout=evaluateWindow(varargin)
        varargout=generateParameter(varargin)
        varargout=process(varargin)
        varargout=getResult(varargin)
        varargout=generatePatches(varargin)
    end    
    %%
    methods (Static=true)
        varargout=generateWindow(varargin)
        varargout=generateExample(varargin)
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=calculateFFT(varargin)
        varargout=compareArrays(varargin)
        varargout=identifyContent(varargin)
    end
end