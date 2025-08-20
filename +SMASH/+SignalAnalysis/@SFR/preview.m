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
%    -'JunkChance', which is the probability of picking up a noise
%    artifact during each time step.  The default value is 0.01, and any
%    number between 0 and 1 can be specified
%    -'Cutoff', which defines the minimum content SNR (in dB).  The default
%    value is -10, and any real number can be specified.  Setting this
%    option to -inf retains all non-junk content.
%    -'Plot' which controls automatic plot generation.  The value can be
%    'on' (default) or 'off'.
%
% See also SFR, estimateNoise, reduce, plot
%
function preview(object,varargin)

% manage input
option=processOptions(varargin{:});

% generate preview
for n=1:numel(object)
    src=object(n).Noise.Source;
    ready=strcmp(src,'set') || strcmpi(src,'estimate');
    if ~ready
        warning('Using default noise setting(s) for %s--preview may not be reliable',...
            object(n).Name);
    end
    [~,parameter]=setTimeScale(object(n));    
    parameter=updateParameter(parameter,option);
    local=@(tcenter,data) analyzeSteps(tcenter,data,parameter);
    data=process(object(n),local);
    data(:,4)=10*log10(data(:,4)); % express SNR in decibels
    % negative frequencies
    index=(data(:,2) > 0);
    new=data(index,:);
    new(:,2)=-new(:,2);
    data=[data; new]; %#ok<AGROW> 
    % store result
    result.Data=sortrows(data,1);
    result.Parameter=parameter;    
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
function out=analyzeSteps(tcenter,data,parameter)

ArrayHeight=1e6;
out=zeros(ArrayHeight,4); % time mean std SNR

fn=parameter.NormalizedFrequency;
band=parameter.NormalizedBand;
keep=(fn >= band(1)) & (fn <= band(2));
fn=fn(keep);
N=numel(fn);
background=parameter.NoiseSpectrum(keep);

start=0;
while ~isempty(tcenter) && ~isnan(tcenter(1))
    % grab local data
    local=parameter.Window.*data(1:parameter.DurationPoints);
    t0=tcenter(1);
    tcenter=tcenter(2:end);
    data=data((1+parameter.StepPoints):end);
    % identify spectral content
    [~,power]=parameter.TransformFcn(local);
    power=power(keep);
    ratio=power./background;
    while true
        [~,index]=max(ratio);
        if ratio(index) <= parameter.Threshold
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
        power(index)=0;
        ratio(index)=0;
        amplitude=sqrt(trapz(x,y)*parameter.PowerScaling);
        SNR=amplitude/parameter.RMS;
        if (10*log10(SNR)) < parameter.Cutoff
            continue
        end
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