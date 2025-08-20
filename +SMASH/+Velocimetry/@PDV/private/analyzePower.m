% under construction
%
% The output "raw" is a cell array the same sizes as the object Channel
% property.  Each element of this array is a cell array of SignalGroup
% objects.
%

function [raw,object]=analyzePower(object,region)

% verify options
try    
    default=object.findPeak([]);
    name=fieldnames(default);
    option=object.HistorySettings.AnalysisOptions;
    for n=1:numel(name)
        if ~isfield(option,name{n})
            option.(name{n})=default.(name{n});
        end
    end
    object.HistorySettings.AnalysisOptions=option;
catch
     error('ERROR: invalid power analysis option(s)');    
end

% process ROIs
raw=cell(size(object.Channel));
N=numel(region);
for m=1:object.NumberChannels
    fprintf('Analyzing channel %d:  region   ',m);
    % prepare analysis parameters    
    offset=object.OffsetFrequency(m);
    F2Vscale=(object.Wavelength(m)/2)/object.VelocityCorrection(m); % frequncy to velocity scale
    MinWidth=2/object.Partition.Duration*F2Vscale;
    fs=object.SampleRate(m);   
    duration=object.Channel{m}.Partition.Duration;    
    switch object.HistorySettings.FFToptions.Window
        case 'hann'
            duration=duration*(0.34/0.58);
        case 'hamming'
            duration=duration*(0.37/0.58);
    end
    background=shift(object.NoiseSpectrum{m},-offset);
    RMSnoise=object.Noise(m);
    IdealAmplitude=lookup(object.PrivateIdealSpectrum{m},0);
    % analyze ROIs
    temp=cell(size(region));    
    for n=1:N
        fprintf('\b\b%2d',n);
        active=region(n);
        if isempty(active.Data)
            table=object.Channel{m}.Measurement.Grid;
            table=[table(1); table(end)];
            fmax=object.SampleRate(m)/2-object.OffsetFrequency(m);
            fmin=-object.OffsetFrequency(m);
            table(:,2)=(fmin+fmax)/2*F2Vscale;
            table(:,3)=(fmax-fmin)/2*F2Vscale;
            active=define(active,table);
        end
        start=min(active.Data(:,1));
        stop=max(active.Data(:,1));
        fragment=object.Channel{m};
        fragment.Normalization='none';
        fragment.Measurement=crop(fragment.Measurement,[start stop]);        
        temp{n}=analyze(fragment,@processBlock);       
        temp{n}.Legend={sprintf('Velocity %d-%d',m,n) sprintf('Uncertainty %d-%d',m,n) sprintf('Amplitude %d-%d',m,n)};
        temp{n}.Name=sprintf('PDV channel %d, ROI %d',m,n);
    end
    fprintf('\n');
    raw{m}=temp;    
end
%%
    function result=processBlock(spectrum,block)
        % look up velocity bounds        
        t=block.Grid;
        t0=(t(1)+t(end))/2;        
        [center,width]=report(active,t0);        
        width=max(width,MinWidth);
        vmax=center+width;
        vmin=center-width;      
        % convert frequency to velocity and bound
        v=(spectrum.Grid-offset)*F2Vscale;
        spectrum=reset(spectrum,v,[]);
        spectrum=spectrum-background;
        spectrum=replace(spectrum,spectrum.Data < 0 ,0);
        spectrum=crop(spectrum,[vmin vmax]);        
        % analyze peak region
        peak=object.findPeak(spectrum,object.HistorySettings.AnalysisOptions);
        location=peak.Location;
        amplitude=sqrt(peak.Amplitude/IdealAmplitude);
        eta=RMSnoise/amplitude;        
        uncertainty=sqrt(6/(fs*duration^3))*eta/pi;
        uncertainty=uncertainty*F2Vscale;        
        result=[location uncertainty amplitude];
    end

end