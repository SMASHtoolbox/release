% reduce Perform frequency reduction
%
% This method performs frequency reduction using the current time/point,
% window, and noise settings.  Results are stored as a new structure
% element of the Reduction property.
%    reduce(object,name,value,...);
% Optional name/value pairs control details of reduction analysis.
% Supported options include:
%    -'JunkRate', which adjusts the internal threshold for distinguishing
%    meaningful content from noise.  The default value of 1 permits
%    an average of one noise artifact per time step.  Any value > 0 can be
%    specified.
%    -'Plot' which controls automatic plot generation.  The value can be
%    'on' (default) or 'off'.
%    -'MaxPeaks', which controls the number of spectral peak that can be
%    used in reduction.  The default value is 10, but any integer >= 1 can
%    be specified.
%    -'Cutoff', which stops reduction when the current peak's SNR falls
%    below a certain value (in dB).  The default value is -inf, which means
%    that reduction never stops prematurely.
%    -'SafetyFactor', which scales uncertainty estimates upwards.  The
%    default value is 3, and any number >=1 can be used.
%
% Parallel analysis is automatically applied when the Parallel Computing
% Toolbox is present *and* a pool of workers has already been created.
%
% See also SFR, gcp, parpool, preview
%
function varargout=reduce(object,varargin)

% manage input
option=struct('JunkRate',1,'Plot','on',...
    'MaxPeaks',10,'Cutoff',-inf,...
    'SafetyFactor',3);
try
    option=SMASH.Developer.options2struct(option,varargin{:});
catch ME
    throwAsCaller(ME);
end

assert(testNumber(option.JunkRate) && (option.JunkRate > 0),...
    'ERROR: junk rate must be a number > 0');
if strcmpi(option.Plot,'on')
    option.Plot=true;
elseif strcmpi(option.Plot,'off')
    option.Plot=false;
else
    error('ERROR: plot option must be ''on'' or ''off''');
end
assert(testNumber(option.MaxPeaks) && (option.MaxPeaks >= 1),...
    'ERROR: maximum peaks per region must be a number >= 1');
option.MaxPeaks=ceil(option.MaxPeaks);
assert(testNumber(option.SafetyFactor) && (option.SafetyFactor >= 1),...
    'ERROR: safety factor must be a number >= 1');

% perform reduction
complete=cell(size(object));
for n=1:numel(object)
    src=object(n).Noise.Source;
    ready=strcmp(src,'set') || strcmpi(src,'estimate');
    if ~ready
        warning('Using default noise setting(s) for %s--result may not be reliable',...
            object(n).Name);
    end    
    parameter=generateParameter(object(n),option);
    local=@(tcenter,data) processStep(tcenter,data,parameter);
    data=process(object(n),local);
    data(:,4)=10*log10(data(:,4)); % express SNR in decibels
    result.Data=data(:,1:4);
    [~,index]=uniquetol(data(:,1),1/object(n).SampleRate);
    complete{n}=[data(index,1) data(index,5)];    
    list={'SampleRate' 'FrequencyBand' ...
        'RiseTime' 'FullTime' 'EffectiveTime' 'StepTime' ...
        'TransformPoints' 'TotalSteps'};
    for k=1:numel(list)
        name=list{k};
        result.(name)=object(n).(name);
    end
    result.RMS=object(n).Noise.RMS;
    result.Window.Name=object(n).Window.Name;
    result.Window.Parameter=object(n).Window.Parameter;
    result.Generated=datestr(now);
    result.Options=option;
    result=orderfields(result);
    if isempty(object(n).Reduction)
        object(n).Reduction=result;
    else
        object(n).Reduction(end+1)=result;
    end
    if option.Plot
        plot(object(n),'reduction');
    end
end

% manage output
if nargout == 0
    for n=1:numel(complete)
        if ~all(complete{n}(:,2))
            warning('Incomplete reduction for %s',object(n).Name);
        end
    end
else
    varargout{1}=complete;
end

end

%%
function out=processStep(tcenter,data,parameter)

ArrayHeight=1e6;
out=zeros(ArrayHeight,5); % time location uncertainty quality complete

fn=parameter.NormalizedFrequency;
band=parameter.NormalizedBand;
keep=(fn >= band(1)) & (fn <= band(2));
fn=fn(keep);
background=parameter.NoiseSpectrum(keep);

M=numel(parameter.Selection);
center=nan(1:M);
width=nan(1:M);

start=0;
while ~isempty(tcenter) && ~isnan(tcenter(1))
    % grab local data
    local=parameter.Window.*data(1:parameter.FullPoints);
    t0=tcenter(1);    
    tcenter=tcenter(2:end);
    data=data((1+parameter.StepPoints):end);
    % check selected ROIs, if defined
    if M > 0       
        for m=1:M
            [center(m),width(m)]=report(parameter.Selection(m),t0);
        end
        if all(isnan(center))
            continue
        end
    end    
    [~,~,transform]=parameter.TransformFcn(local);
    transform=transform(keep);    
    % process content
    [location,uncertainty,SNR,complete]=reduceSpectrum(...
        fn,transform,background,parameter);        
    Lnew=numel(location);
    while (start + Lnew) > size(out,1)
        out(end+ArrayHeight,end)=0;
    end
    start=start+1;
    stop=start+Lnew-1;
    index=start:stop;
    out(index,1)=t0;
    out(index,2)=location;
    out(index,3)=uncertainty;
    out(index,4)=SNR;    
    out(index,5)=complete;
    start=stop;    
end
out=out(1:start-1,:);

end

%%
function [location,uncertainty,SNR,complete]=...
    reduceSpectrum(fn,z,bg,parameter)

complete=false;
X=real(z);
Y=imag(z);

location=nan(1,parameter.MaxPeaks);
SNR=nan(1,parameter.MaxPeaks);
N=numel(fn);
for m=1:parameter.MaxPeaks
    remain=X.^2+Y.^2;
    [~,index]=max(remain);    
    ratio=remain(index)/bg(index);
    if ratio <= parameter.NormalizedThreshold
        complete=true;
        break   
    end
    f0=fn(index);
    if (index > 1) && (index < N)
        index=(index-1):(index+1);
        u=fn(index)-f0;
        scale=max(u);
        u=u/scale;
        v=remain(index);
        v=v/max(v);
        param=polyfit(u,v,2);
        f0=f0+scale*roots(polyder(param));         
    end    
    G1=parameter.WindowTransform(fn-f0);
    G2=parameter.WindowTransform(fn+f0);
    H1=parameter.ConjugateTransform(fn-f0);
    H2=parameter.ConjugateTransform(fn+f0);
    Xbasis=[(G1+G2) (H1+H2)];
    %weight=spdiags(remain,0,N,N);
    %weight=spdiags(sqrt(remain),0,N,N);
    %[Xscale,~]=linsolve(weight*Xbasis,weight*X);
    [Xscale,~]=linsolve(Xbasis,X);
    Xfit=Xbasis*Xscale;
    X=X-Xfit;
    Ybasis=[(G1-G2) (H1-H2)];
    if rank(Ybasis) > 0 % imaginary basis is zero when f0=0
        %[Yscale,~]=linsolve(weight*Ybasis,weight*Y);
        [Yscale,~]=linsolve(Ybasis,Y);
        Yfit=Ybasis*Yscale;
        Y=Y-Yfit;
    else
        Yscale=[0 0];
    end
    Xscale2=Xscale(1).^2+Xscale(2).^2;
    Yscale2=Yscale(1).^2+Yscale(2).^2;
    amplitude=sqrt(Xscale2+Yscale2)*parameter.AmplitudeScaling;
    if amplitude == 0
        keyboard
    end
    location(m)=f0;
    SNR(m)=amplitude/parameter.RMS;
    if SNR(m) < parameter.Cutoff
        complete=true;
        break
    end 

end   

keep=isfinite(location);
location=location(keep)*parameter.SampleRate;
SNR=SNR(keep);
uncertainty=parameter.NormalizedUncertaintyScaling./SNR;
uncertainty=parameter.SafetyFactor*uncertainty*parameter.SampleRate;

%[location,index]=sort(location);
%SNR=SNR(index);
%uncertainty=uncertainty(index);


end