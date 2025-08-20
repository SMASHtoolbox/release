% setFrequencyBand Set frequency band edges
%
% This method sets the frequency band edges used by the preview and reduce
% methods.
%    setFrequencyBand(object,value);
% The input "value" is typically a two-element array [low high].  Low
% frequency values are bounded by zero, and high frequency values are
% bounded by the Nyquist limit.  The command:
%    setFrequencyBand(object,'full');
% adjusts the band to cover all supported frequencies.
%
% Automatic band selection:
%    setFrequencyBand(object,'auto',threshold);
% uses the noise spectrum shape to determine the high frequency edge.  The
% optional input "threshold" controls the fractional area of the noise
% spectrum to be included in the band; the default value is 0.95.
%
% See also SFR, estimateNoise, setNoise, preview, reduce
%
function setFrequencyBand(object,value,threshold)

assert(nargin > 1,'ERROR: insufficient input');
for n=1:numel(object)
    nyquist=object(n).SampleRate/2;
    if isnumeric(value)
        assert(numel(value) == 2,...
            'ERROR: frequency band should be [low high]');
        value=sort(value);
        assert(diff(value) > 0,...
            'ERROR: frequency band cannot have zero width');
        value(1)=max(value(1),0);
        value(2)=min(value(2),nyquist);
        object(n).FrequencyBand=value;
    elseif strcmpi(value,'full')
        object(n).FrequencyBand=[0 nyquist];
    elseif strcmpi(value,'auto')
        if (nargin < 3) || isempty(threshold)
            threshold=0.95;
        else
            assert(testNumber(threshold) && (threshold > 0) && (threshold < 1),...
                'ERROR: area threshold must be a number between 0 and 1');            
            if threshold <= 0.90
                warning('Area threshold should *usually* be > 0.90');
            end
        end                
        src=object(n).Noise.Source;
        ready=strcmp(src,'set') || strcmp(src,'setShape') || strcmpi(src,'estimate');
        if ~ready
        warning('Using default noise shape for %s.  Frequency band estimate may not be reliable',...
            object(n).Name);
        end        
        value=[0 0];
        fn=linspace(0,0.5,1000);
        z=object.Noise.ShapeFcn(fn);
        z=cumtrapz(fn,z);
        z=z/z(end);        
        index=find(z < threshold,1,'last');
        value(2)=fn(index)*object(n).SampleRate;
        object(n).FrequencyBand=value;
    else
        error('ERROR: invalid frequency band setting');
    end
end

end