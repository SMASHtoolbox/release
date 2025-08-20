% This class analyzes Photonic Doppler Velocimetry (PDV) measurements.  To
% analyze an individual measurement:
%    object=PDV(time,signal); % numeric arrays
%    object=PDV(source); % source object (Signal or STFT class)
%    object=PDV(file,format,channel); % data file
% The inputs "format" and "channel" may be optional for some file formats.
%
% Multiple measurements can also be linked together by passing a list of
% objects and/or cell arrays of numeric/file input for each channel.
%    object=PDV({time1,signal1},{time2,signal2},...); % numeric arrays
%    object=PDV(source1,source2,...); % source objects
%    object=PDV({file1,format1,CH2},{file2,format2,CH2},...); % data files
% Different formats can be used for each channel: files can be mixed with
% numeric arrays, number arrays with source objects, and so forth.
% Channels are labelled in the order they are specified.
% NOTE: linked measurements should only be used for channels that measure
% the same velocity!  Distinct PDV measurements should be analyzed separately.
%
% Time-frequency spectrograms are automatically generated at object
% creation unless otherwise indicated.
%    object=PDV('-nospectrogram',...); % disable automatic spectrogram generation
% Spectrograms are used for visualization and region selection, but play no
% direct role in history generation.  Large-scale, batch analysis with no
% interactive selections do not require spectrogram generation.
%
% The Status property indicates the current state of an object's
% spectrogram, region of interest selection, noise characterization, and
% history calculation.  Each status begins with the value
% 'incomplete' and becomes 'complete' when the relevant method has been
% called.  Some modifications, such as the partition method, result in a
% 'complete' state becoming 'obsolete'.  Obsolete results should be handled
% with caution--they may be inconsisent with the current analysis settings.
%
%
% Examples:
%    <a href="matlab:SMASH.System.showExample('RampDemo','+SMASH/+Velocimetry/@PDV')">Ramp wave</a>
%    <a href="matlab:SMASH.System.showExample('ShockDemo','+SMASH/+Velocimetry/@PDV')">Shock wave</a>
%
%
% See also SMASH.Velocimetry, SMASH.SignalAnalysis.STFT,
% SMASH.SignalAnalysis.Signal, SMASH.ImageAnalysis.Image, SMASH.ROI.Curve
%
classdef PDV
    %%
    properties  
        Name = 'PDV object' % Object name (text)
        Comments = '(empty)' % Optional comments (text)        
    end
    properties (Dependent=true)
        Wavelength % Optical wavelengths (numeric array)
        VelocityCorrection % Simple window corrections (numeric array)
        OffsetFrequency % Offset frequencies (numeric array)
        FFTwindow % Transform window ('hann', 'hamming', or 'boxcar')
        FFTbins % Number of transform frequencies ([min max])
    end
    properties (Dependent=true, Hidden=true)
        FFToptions % FFT options (object)
    end
    properties (Access=protected, Hidden=true)
        PrivateWavelength
        PrivateVelocityCorrection
        PrivateOffsetFrequency
    end
    properties (SetAccess=protected)
        Channel = {} % Measured channels with a common velocity (cell array of STFT objects)
        NumberChannels % Number of PDV channels (integer)
        TimeShift % Time shift values (numeric array)
        TimeScale % Time scale values (numeric array)
        SampleRate % Data sample rates (numeric array)                
        ReferenceSelection % Reference region time range ([start stop])
    end
    properties (Dependent=true)
        Bandwidth % Maximum usable bandwidth (numeric array)
    end    
    properties (SetAccess=protected, Hidden=true)
        PrivateBandwidth 
    end
    properties (Dependent=true)
        ColorMap % Spectrogram color map (three-column numeric table)
        Label % Variable labels (structure)
    end
    properties (SetAccess=protected, Hidden=true)
        PrivateLabel
    end
    properties (SetAccess=protected, Dependent=true)
        Spectrogram % Preview spectrogram (cell array of Image objects)
    end
    properties (SetAccess=protected)
        SpectrogramSettings % Analysis settings for preview spectrograms (structure)
    end       
    properties (SetAccess=protected, Hidden=true)
        PrivateSpectrogram = {}        
    end
    properties (Dependent=true, SetAccess=protected)
        Partition % Current partition settings (structure)
    end    
    properties (SetAccess=protected)
        Noise % Time-domain RMS noise (scalar or two-column array)    
    end
    properties (SetAccess=protected, Dependent=true)
        NoiseSpectrum % Estimated noise power spectrum (cell array of Signal objects)
        %IdealSpectrum % Ideal power spectrum 
    end
    properties (SetAccess=protected, Hidden=true)
        PrivateNoiseSpectrum
        PrivateIdealSpectrum 
    end    
    properties (SetAccess=protected)
        ROIselection % Selected regions of interest (Curve object)
        History % Velocity histories (cell array of objects)
        HistorySettings % Analysis settings for velocity histories (structure)
    end
    properties (Dependent=true, SetAccess=protected)
        NumberHistories % Number of velocity histories (integer)
    end
    properties (SetAccess=protected)
        Status % Status report (structure)
    end
    properties
        ExportMode = 'standard' % Export mode ('standard' or 'compact')
        ShowNegativeFrequencies = false % Show negative frequencies (true or false)
    end
    %%
    methods (Hidden=true)
        function object=PDV(varargin)
            % manage input
            GenerateSpectrogram=true;
            if (nargin() > 0) && ischar(varargin{1}) && strcmpi(varargin{1},'-nospectrogram')
                GenerateSpectrogram=false;
                varargin=varargin(2:end);
            end
            if numel(varargin) == 0
                varargin{1}=SMASH.SignalAnalysis.Signal();
            end
            while numel(varargin) > 0
                if isobject(varargin{1})
                    if strcmpi(class(object),class(varargin{1}))
                        for k=1:varargin{1}.NumberChannels
                            object.Channel{end+1}=varargin{1}.Channel{k};
                        end
                    else
                        object.Channel{end+1}=SMASH.SignalAnalysis.STFT(varargin{1});
                    end
                    varargin=varargin(2:end);
                elseif iscell(varargin{1})
                    temp=varargin{1};
                    object.Channel{end+1}=SMASH.SignalAnalysis.STFT(temp{:});
                    varargin=varargin(2:end);
                else
                    object.Channel{1}=SMASH.SignalAnalysis.STFT(varargin{:});
                    varargin={};
                end
            end
           % fill out properties
           object.Status=struct(...
               'Spectrogram','incomplete','Reference','incomplete',...
               'ROI','incomplete','Noise','incomplete',...
               'History','incomplete');
           object.NumberChannels=numel(object.Channel);
           object.TimeShift=zeros(size(object.Channel));
           object.TimeScale=ones(size(object.Channel));
           for n=1:object.NumberChannels
               temp=object.Channel{n}.Measurement;
               dt=abs(temp.Grid(end)-temp.Grid(1))/(numel(temp.Grid)-1);
               object.SampleRate(n)=1/dt;
               object.Channel{n}.Name=sprintf('Channel %d',n);   
               object.Channel{n}.Normalization='none';
           end                      
           object.Bandwidth=[];
           [object,Npoints]=generateCommonTimeBase(object);
           Nblocks=floor(Npoints/100);
           Nblocks=min(Nblocks,1000);
           for n=1:object.NumberChannels
               object.Channel{n}=partition(object.Channel{n},...
                   'blocks',[Nblocks 0]);
           end           
           object.FFToptions=SMASH.General.FFToptions(...
               'NumberFrequencies',[1e3 10e3],'RemoveDC',true,...
               'Window','hann','Normalization','none',...
               'SpectrumType','power','FrequencyDomain','all');
           object.PrivateWavelength=repmat(1550e-9,size(object.Channel));
           object.PrivateVelocityCorrection=ones(size(object.Channel));
           object.PrivateOffsetFrequency=zeros(size(object.Channel));
           object.Noise=nan(size(object.Channel));
           object.PrivateNoiseSpectrum=cell(size(object.Channel));
           object.Label=[];
           %       
           if GenerateSpectrogram
               object=generateSpectrogram(object);
               object.SpectrogramSettings.FFToptions=object.FFToptions;
           end
           %
           object.HistorySettings.FFToptions=object.FFToptions;
           object.HistorySettings.Analysis='power';
           object.HistorySettings.AnalysisOptions.Mode='centroid';
        end
        varargout=changeStatus(varargin)
        varargout=guessROI(varargin)
        varargout=removeROI(varargin)
    end
    %%
    methods (Static=true)
        varargout=findPeak(varargin)
        varargout=demonstrate(varargin)
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin)
    end    
    %% getters
    methods        
        function value=get.Wavelength(object)
            value=object.PrivateWavelength;
        end
        function value=get.VelocityCorrection(object)
            value=object.PrivateVelocityCorrection;
        end        
        function value=get.OffsetFrequency(object)
            value=object.PrivateOffsetFrequency;
        end
        function value=get.FFTwindow(object)
            value=object.FFToptions.Window;
        end
        function value=get.FFTbins(object)
            value=object.FFToptions.NumberFrequencies;
        end
        function value=get.FFToptions(object)
            value=object.Channel{1}.FFToptions;
        end        
        function value=get.Bandwidth(object)
            value=object.PrivateBandwidth;
        end
        function value=get.ColorMap(object)
            if isempty(object.PrivateSpectrogram)
                value=[];
            else
                value=object.PrivateSpectrogram{1}.GraphicOptions.ColorMap;
            end
        end
        function value=get.Label(object)
            value=object.PrivateLabel;
        end
        function value=get.Spectrogram(object)
            value=object.PrivateSpectrogram;
            if isempty(value)
                return
            end            
            for n=1:object.NumberChannels
                if object.ShowNegativeFrequencies
                    value{n}=crop(value{n},...
                        [],[-object.Bandwidth(n) +object.Bandwidth(n)]);
                else
                    value{n}=crop(value{n},...
                        [],[0 +object.Bandwidth(n)]);
                end
                value{n}=shift(value{n},'Grid2',-object.OffsetFrequency(n));
                F2Vscale=(object.Wavelength(n)/2)/object.VelocityCorrection(n);
                value{n}=scale(value{n},'Grid2',F2Vscale);              
                value{n}.Grid1Label=object.Label.Time;               
                value{n}.Grid2Label=object.Label.Velocity;
                value{n}.DataLabel='Relative power';
                value{n}.Name=sprintf('Channel %d spectrogram',n);
            end
        end  
        function value=get.Partition(object)
            value=object.Channel{1}.Partition;
        end
        function value=get.NoiseSpectrum(object)
            value=object.PrivateNoiseSpectrum;
            if isempty(value)
                return
            end
            for n=1:object.NumberChannels
                value{n}=shift(value{n},-object.OffsetFrequency(n));
                F2Vscale=(object.Wavelength(n)/2)/object.VelocityCorrection(n);
                value{n}=scale(value{n},F2Vscale);
                value{n}.GridLabel=object.Label.Velocity;
            end
        end
        %function value=get.IdealSpectrum(object)
        %    value=object.PrivateIdealSpectrum;
        %    if isempty(value)
        %        return
        %    end
        %    for n=1:object.NumberChannels
        %        value{n}=shift(value{n},-object.OffsetFrequency(n));
        %        F2Vscale=(object.Wavelength(n)/2)/object.VelocityCorrection(n);
        %        value{n}=scale(value{n},F2Vscale);
        %        value{n}.GridLabel=object.Label.Velocity;
        %    end
        %end
        function value=get.NumberHistories(object)
            if isempty(object.History)
                value=[];
            else
                value=numel(object.History);
            end
        end
    end
    %% setters
    methods       
        function object=set.Name(object,value)
            assert(ischar(value),'ERROR: invalid name');
            object.Name=value;
        end
        function object=set.Comments(object,value)
            assert(ischar(value),'ERROR: invalid comments');
            object.Comments=value;
        end               
        function object=set.Wavelength(object,value)
            if isempty(value)
                value=repmat(1550e-9,size(object.Channel));
            else
                assert(isnumeric(value) && all(value > 0),...
                    'ERROR: invalid wavelength value(s)');
                if isscalar(value)
                    value=repmat(value,size(object.Channel));
                else
                    assert(numel(value) == numel(object.Channel),...
                        'ERROR: invalid number of wavelength values');
                    value=reshape(value,size(object.Channel));
                end
            end
            object.PrivateWavelength=value; 
            object=changeStatus(object,'obsolete','History');
        end
        function object=set.VelocityCorrection(object,value)
            if isempty(value)
                value=ones(size(object.Channel));
            else
                assert(isnumeric(value),...
                    'ERROR: invalid velocity correction(s)');
                if isscalar(value)
                    value=repmat(value,size(object.Channel));
                else
                    assert(numel(value) == numel(object.Channel),...
                        'ERROR: invalid number of velocity corrections');
                    value=reshape(value,size(object.Channel));
                end
            end
            object.PrivateVelocityCorrection=value; 
            object=changeStatus(object,'obsolete','History');
        end        
        function object=set.OffsetFrequency(object,value)
             if isempty(value)
                value=zeros(size(object.Channel));
            else
                assert(isnumeric(value),...
                    'ERROR: invalid offset frequency value(s)');
                if isscalar(value)
                    value=repmat(value,size(object.Channel));
                else
                    assert(numel(value) == numel(object.Channel),...
                        'ERROR: invalid number of offset frequency values');
                    value=reshape(value,size(object.Channel));
                end
            end
            object.PrivateOffsetFrequency=value;   
            object=changeStatus(object,'obsolete','ROI','History');
        end        
        function object=set.Bandwidth(object,value)            
            if isempty(value)
                value=nan(size(object.Channel));
                for n=1:object.NumberChannels
                    value=object.SampleRate/2;
                end               
            end
            assert(isnumeric(value) && all(value > 0),...
                'ERROR: invalid bandwidth value(s)');
            if isscalar(value)
                value=repmat(value,size(object.Channel));                
            else
                assert(numel(value) == object.NumberChannels,...
                    'ERROR: invalid number of bandwidth values');
                value=reshape(value,size(object.Channel));
            end
            if value >= object.SampleRate/2
                fprintf('Bandwidth set to Nyquist limit\n');
            end
            value=min(value,object.SampleRate/2);
            object.PrivateBandwidth=value;           
            object=changeStatus(object,'obsolete');
        end
        function object=set.FFTwindow(object,value)
            try
                object.FFToptions.Window=value;
            catch
                error('ERROR: invalid transform window');
            end
             % update status?
        end
        function object=set.FFTbins(object,value)
            try
                object.FFToptions.NumberFrequencies=value;
            catch
                error('ERROR: invalid number of transform frequencies');
            end
            % update status?
        end
        function object=set.FFToptions(object,value)
            if isempty(object.FFToptions)
                % do nothing
            else
                assert(strcmp(class(value),class(object.FFToptions)));               
            end
            % compare new and previous settings
            for n=1:object.NumberChannels
                object.Channel{n}.FFToptions=value;
            end           
        end          
        function object=set.ColorMap(object,value)
            for n=1:numel(object.Spectrogram)
                try
                    object.PrivateSpectrogram{n}.GraphicOptions.ColorMap=value;
                catch
                    error('ERROR: invalid color map');
                end
            end
        end
        function object=set.Label(object,value)
            if isempty(value)
                value=struct('Wavelength','Wavelength','Time','Time',...
                    'Frequency','Frequency','Velocity','Velocity',...
                    'Uncertainty','Uncertainty','Amplitude','Amplitude');
            else
                assert(isstruct(value),'ERROR: invalid label name');
                name=fieldnames(value);
                for k=1:numel(name)
                    assert(isfield(object.PrivateLabel,name{k}),...
                        'ERROR: invalid label name');
                    new=value.(name{k});
                    assert(ischar(new) || iscellstr(new),...
                        'ERROR: invalid label value');
                end
            end
            object.PrivateLabel=value;
            for k=1:object.NumberChannels
                object.Channel{k}.Measurement.GridLabel=value.Time;
            end
            for k=1:object.NumberHistories
                object.History{k}.GridLabel=value.Time;
                object.History{k}.Legend{1}=value.Velocity;
                object.History{k}.Legend{2}=value.Uncertainty;
                object.History{k}.Legend{3}=value.Amplitude;
            end
        end
        function object=set.ExportMode(object,value)
            errmsg='ERROR: invalid export mode';
            assert(ischar(value),errmsg);
            value=lower(value);
            switch value
                case {'standard' 'compact'}
                    object.ExportMode=value;
                otherwise
                    error(errmsg);
            end
        end        
        function object=set.ShowNegativeFrequencies(object,value)
            assert(islogical(value) && isscalar(value),...
                'ERROR: value must be true or false');
            object.ShowNegativeFrequencies=value;
        end
    end
end