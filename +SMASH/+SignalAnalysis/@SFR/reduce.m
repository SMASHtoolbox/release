% reduce Perform frequency reduction
%
% This method performs frequency reduction using the current time/point,
% window, and noise settings.  Results are stored as a new structure
% element of the Reduction property.
%    reduce(object,name,value,...);
% Optional name/value pairs control details of reduction analysis.
% Supported options include:
%    -'JunkChance', which adjusts the internal threshold for distinguishing
%    meaningful content from noise.  The default value of 1 permits
%    an average of one noise artifact per time step.  Any value > 0 can be
%    specified.
%    -'Cutoff', which stops reduction when the current peak's SNR falls
%    below a certain value (in dB).  The default value is 0.
%    -'Plot' which controls automatic plot generation.  The value can be
%    'on' (default) or 'off'.
%
% Serial reduction is performed by default.  Parallel reductionis used when:
%
%are performned when: is automatically applied when the Parallel Computing
% Toolbox is present *and* a pool of workers has already been created.
%
% See also SFR, gcp, parpool, preview
%
function reduce(object,varargin)

% manage input
option=processOptions(varargin{:});

% perform reduction
for n=1:numel(object)
    src=object(n).Noise.Source;
    ready=strcmp(src,'set') || strcmpi(src,'estimate');
    if ~ready
        warning('Using default noise setting(s) for %s--result may not be reliable',...
            object(n).Name);
    end
    [~,parameter]=setTimeScale(object(n));
    parameter=updateParameter(parameter,option);  
    parameter.Selection=object(n).Selection;
    local=@(tcenter,data) analyzeSteps(tcenter,data,parameter);
    data=process(object(n),local);
    data(:,4)=10*log10(data(:,4)); % express SNR in decibels    
    result.Data=sortrows(data,[1 4],{'ascend' 'descend'});   
    result.Data(:,end+1)=1; % enable
    result.Parameter=parameter;   
    if isempty(object(n).Reduction)
        object(n).Reduction=result;
    else
        object(n).Reduction(end+1)=result;
    end
    if option.Plot        
        plot(object(n),'reduction');
    end
end

end

%%
function out=analyzeSteps(tcenter,data,parameter)

ArrayHeight=1e6;
out=zeros(ArrayHeight,4); % t f df SNR

fn=parameter.NormalizedFrequency;
band=parameter.NormalizedBand;
keep=(fn >= band(1)) & (fn <= band(2));
fn=fn(keep);
background=parameter.NoiseSpectrum(keep);
Nfn=numel(fn);

counter=0;
while ~isempty(tcenter) && ~isnan(tcenter(1))
    % grab local data
    t0=tcenter(1);
    tcenter=tcenter(2:end);
    local=parameter.Window.*data(1:parameter.DurationPoints);
    data=data((1+parameter.StepPoints):end);
    % local transform
    [~,~,transform]=parameter.TransformFcn(local);
    transform=transform(keep);
    % ROI management    
    if isempty(parameter.Selection)
        bound=[-inf +inf];
    else
        mask=zeros(size(transform));
        M=numel(parameter.Selection);
        bound=nan(M,2);
        for m=1:M
            [center,width]=report(parameter.Selection(m),t0);
            bound(m,1)=center-width;
            bound(m,2)=center+width;
            center=abs(center); % in case ROI includes f < 0
            index=(abs(fn*parameter.SampleRate-center) <= width);
            mask(index)=1;
        end          
        bound=bound(isfinite(bound(:,1)),:);
        transform=mask.*transform;
    end       
    % local reduction
    X=real(transform);
    Y=imag(transform);
    while ~isempty(transform)
        remain=(X.^2+Y.^2);
        ratio=remain./background;       
        [ratio,index]=max(ratio);
        if ratio <= parameter.Threshold           
            break
        end
        fn0=fn(index);
        if (index > 1) && (index < Nfn) % quadratic refinement
            index=(index-1):(index+1);
            u=fn(index)-fn0;
            scale=max(u);
            u=u/scale;
            v=remain(index);
            v=v/max(v);
            param=polyfit(u,v,2);
            fn0=fn0+scale*roots(polyder(param));
        end
        G1=parameter.WindowTransform(fn-fn0);
        G2=parameter.WindowTransform(fn+fn0);
        H1=parameter.ConjugateTransform(fn-fn0);
        H2=parameter.ConjugateTransform(fn+fn0);
        Xbasis=[(G1+G2) (H1+H2)];
        [Xscale,~]=linsolve(Xbasis,X);
        Xfit=Xbasis*Xscale;
        X=X-Xfit;
        Ybasis=[(G1-G2) (H1-H2)];
        if rank(Ybasis) > 0 % imaginary basis is zero at zero frequency
            [Yscale,~]=linsolve(Ybasis,Y);
            Yfit=Ybasis*Yscale;
            Y=Y-Yfit;
        else           
            Yfit=0;
        end
        area=trapz(fn,Xfit.^2+Yfit.^2);
        amplitude=sqrt(area*parameter.PowerScaling);
        SNR=amplitude/parameter.RMS;
        if SNR < parameter.Cutoff
            break
        end
        f0=fn0*parameter.SampleRate;
        new=[t0 f0 parameter.UncertaintyScaling/amplitude SNR];
        for m=size(bound,1)
            if (f0 >= bound(m,1)) && (f0 <= bound(m,2))            
                expandArray();
                break
            end
        end
        new=[t0 -f0 parameter.UncertaintyScaling/amplitude SNR];
        for m=size(bound,1)
            if (-f0 >= bound(m,1)) && (f0 <= bound(m,2))
                expandArray();
                break
            end
        end               
    end
end
out=out(1:counter,:);

    function expandArray()
        counter=counter+1;
        if counter > size(out,1)
            out(end+ArrayHeight,end)=0;
        end
        out(counter,:)=new;
    end

end