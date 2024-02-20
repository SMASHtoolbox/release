% SUMMARIZE Summarize object information
% 
% This method provides a statistical summary of the information stored in a
% Signal object.
%    >> report=summarize(object); 
% The output "report" is a structure describing the Grid and Data contained
% in the limited region.  Calling the method with no output:
%    >> summarize(object);
% prints the summary to the command window.
%
% Information about the sinusoidal content can added to the summary
%    >> report=summarize(object,'sinusoid'); 
% To restrict analysis to a particular frequency range:
%    >> report=summarize(object,'sinusoid','FrequencyBound',[fmin fmax]);
%
% See also Signal, limit
%

%
% created May 1, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised July 11, 2014 by Daniel Dolan
%    -Added Grid summary as a sub-structure
%    -Moved Data summary to a sub-structure
% revised November 6 by Daniel Dolan
%    -Added sinusoid option
%
function varargout=summarize(object,varargin)

% manage input
sinusoid=false;
%FrequencyBound=[-inf +inf];
FrequencyBound=[];
while numel(varargin) > 0
    if strcmpi(varargin{1},'sinusoid')
        sinusoid=true;
        varargin=varargin(2:end);
    elseif strcmp(varargin{1},'FrequencyBound');
        assert(numel(varargin)>=2,'ERROR: invalid input');
        value=varargin{2};
        assert(isnumeric(value) && numel(value)==2,...
            'ERROR: invalid frequency bound');
        FrequencyBound=sort(value);        
        varargin=varargin(3:end);
    else
        error('ERROR: invalid input');
    end
end

% extract Data from limited region
[Grid,Data]=limit(object);
Data=Data(:);

% summarize Grid
report.Grid.Min=min(Grid);
report.Grid.Max=max(Grid);
report.Grid.Range=report.Grid.Max-report.Grid.Min;
report.Grid.Mean=mean(Grid);
dt=report.Grid.Range/(numel(Grid)-1);

% summarize Data
report.Data.Min=min(Data);
report.Data.Max=max(Data);
report.Data.Range=report.Data.Max-report.Data.Min;
report.Data.Mean=mean(Data);
report.Data.Std=std(Data);
report.Data.Median=median(Data);

% sinusoid analysis
nyquist=1/(2*dt);
fmax=nyquist/4;
if isempty(FrequencyBound)
    FrequencyBound=[0 fmax];
end    
if sinusoid
    left=max(0,FrequencyBound(1));
    right=min(FrequencyBound(2),fmax);  
    % characterize peak
    options.RemoveDC=true;
    options.NumberFrequencies=1e6;
    [f,P]=fft(object,options);
    keep=(f>=left) & (f<=right);
    f1=f(keep);
    P1=P(keep);  
    [Pmax,index]=max(P1);
    f0=f1(index);
    report.Sinusoid.Frequency=f0;   
    % characterize noise
    keep=(f>=left) & (f<=right);
    P1=P(keep);
    Pnoise=median(P1);    
    % calibrate peak amplitude
    [t,~]=limit(object);
    s=cos(2*pi*f0*t);
    temp=SMASH.SignalAnalysis.Signal(t,s);
    [f,P]=fft(temp,options);    
    Pref=interp1(f,P,f0);
    report.Sinusoid.Amplitude=sqrt(Pmax/Pref);
    % calibrate noise amplitude 
    arg=-20:+20;
    kernel=exp(-arg.^2/(2*0.75^2));
    kernel=kernel/sum(kernel);
    s=randn(size(t));
    s=conv2(s,kernel(:),'same');
    s=s/std(s);
    temp=reset(temp,[],s);
    [f,P]=fft(temp,options);
    keep=(f>=left) & (f<=right);
    P1=P(keep);
    Pref=median(P1);
    report.Sinusoid.Noise=sqrt(Pnoise/Pref);
    report.Sinusoid.Fraction=...
        report.Sinusoid.Noise/report.Sinusoid.Amplitude;
end

% manage output
if nargout==0
    name=fieldnames(report);
    for m=1:numel(name)        
        fprintf('%s summary:\n',name{m});
        temp=report.(name{m});
        disp(temp);
    end
else
    varargout{1}=report;
end

end