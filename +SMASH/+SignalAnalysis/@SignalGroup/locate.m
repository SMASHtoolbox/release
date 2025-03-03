% LOCATE Locate feature in an object
%
% This method locates features in a SignalGroup object.  By default,
% the feature is assumed to be a single Gaussian peak.
%    >> report=locate(object);
% The output "report" contains information about the located features.
%
% Single Gaussian peak location can be explicitly requested with a second
% input argument.
%    >> report=locate(object,'peak');
% Step location based on the error function is also provided.
%    >> report=locate(object,'step');    
% Custom features may be requested by passing a function handle  that
% provides the desired fit.
%    >> report=locate(object,@myfit);
% The fit function must accept two inputs (x,y) and return a structure
% reporting results of the fit.  One field of this structure, 'Location',
% should identifying the feature's location; additional fields can be used
% as necessary.  The "peak" and "step" fits provide fields for 'Method',
% 'Description', 'Location', 'Width', 'Amplitude', 'Baseline',
% 'Parameters', and 'Fit'.
%
% See also SignalGroup
%

%
% created November 24, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=locate(object,varargin)

% determine grid bounds
x=limit(object);
bound=[min(x) max(x)];

% analyze individual signals
result=cell(1,object.NumberSignals);
for n=1:object.NumberSignals
    temp=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));   
    temp=crop(temp,bound);        
    report=locate(temp,varargin{:});    
    result{n}=report;
end

% handle output
if nargout==0
    view(object);
    label=object.Legend;
    for n=1:object.NumberSignals        
        line(x,result{n}.Fit,'Color','k','LineStyle','--');        
        label{n}=sprintf('%s, Location = %#+g',label{n},result{n}.Location);
    end
    title('SignalGroup locations');
    legend(label,'Location','best');
else
    varargout{1}=result;
end

end