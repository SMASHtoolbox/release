% preview Generate reduction preview
%
% This method generates a simplified frequency reduction preview.
%    preview(object);
% Statistically significant content in the signal is identified in a
% time-dependent manner.  This process is significantly faster than
% complete reduction, providing a quick visualization.
%
% The behavior of this method is controlled with optional name/value pairs.
%    preview(object,name,value,...);
% Valid options include:
%    -'JunkRate', which controls the average number of noise artifacts per
%    time step (default is 1).  Any number > 0 can be specified; large
%    values will result in more noise artifacts, while small values may
%    omit marginal content.
%    -'Plot' which controls automatic plot generation.  The value can be
%    'on' (default) or 'off'.
%
% See also SFR, estimateNoise, reduce, plot
%
function preview(object,varargin)

% manage input
option=struct('JunkRate',1,'Plot','on');
option=SMASH.Developer.options2struct(option,varargin{:});

assert(testNumber(option.JunkRate) && (option.JunkRate > 0),...
    'ERROR: junk rate must be a number > 0');
if strcmpi(option.Plot,'on')
    option.Plot=true;
elseif strcmpi(option.Plot,'off')
    option.Plot=false;
else
    error('ERROR: plot option must be ''on'' or ''off''');
end

% generate preview
for n=1:numel(object)
    src=object(n).Noise.Source;
    ready=strcmp(src,'set') || strcmpi(src,'estimate');
    if ~ready
        warning('Using default noise setting(s) for %s--preview may not be reliable',...
            object(n).Name);
    end
    parameter=generateParameter(object(n),option);
    local=@(tcenter,data) processStep(tcenter,data,parameter);
    data=process(object(n),local);
    data(:,4)=10*log10(data(:,4)); % express SNR in decibels
    result.Data=data;
    list={'SampleRate' 'FrequencyBand' ...
        'RiseTime' 'FullTime' 'EffectiveTime' 'StepTime' ...
        'TransformPoints' 'TotalSteps'};
    for k=1:numel(list)
        name=list{k};
        result.(name)=object.(name);
    end
    result.RMS=object(n).Noise.RMS;
    result.Window.Name=object(n).Window.Name;
    result.Window.Parameter=object(n).Window.Parameter;
    result.Generated=datestr(now);
    result.Options=option;
    result=orderfields(result);
    if isempty(object(n).Preview)
        object(n).Preview=result;
    else
        object(n).Preview(end+1)=result;
    end
    if option.Plot
        plot(object(n),'preview');
    end    
end

end

%%
function out=processStep(tcenter,data,parameter)

ArrayHeight=1e6;
out=zeros(ArrayHeight,4); % time mean std quality

fn=parameter.NormalizedFrequency;
band=parameter.NormalizedBand;
keep=(fn >= band(1)) & (fn <= band(2));
fn=fn(keep);
N=numel(fn);
background=parameter.NoiseSpectrum(keep);

start=0;
while ~isempty(tcenter) && ~isnan(tcenter(1))
    % grab local data
    local=parameter.Window.*data(1:parameter.FullPoints);
    t0=tcenter(1);
    tcenter=tcenter(2:end);
    data=data((1+parameter.StepPoints):end);
    % identify spectral content
    [~,power]=parameter.TransformFcn(local);
    power=power(keep);
    while true
        [~,index]=max(power);
        ratio=power(index)/background(index);
        if ratio <= parameter.NormalizedThreshold
            break
        end
        for left=index:-1:1
            if power(left) < background(left)
                break
            end
        end
        for right=index:1:N
            if power(right) < background(right)
                break
            end
        end
        index=left:right;
        x=fn(index);
        y=power(index);
        amplitude=sqrt(trapz(x,y)*parameter.PowerScaling);
        SNR=amplitude/parameter.RMS;
        power(index)=0;
        L=size(out,1);
        if start > L
            out(L+ArrayHeight,end)=0;
        end
        start=start+1;
        out(start,1)=t0;
        out(start,2)=(x(1)+x(end))/2*parameter.SampleRate;
        out(start,3)=(x(end)-x(1))/2*parameter.SampleRate;
        out(start,4)=SNR;
    end
    
end
out=out(1:start,:);

end