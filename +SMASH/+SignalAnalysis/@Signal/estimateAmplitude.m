% estimateAmplitude Estimate signal amplitude
%
% This method estimates signal amplitude using a statistical approach.
% First, signal data is separated into values above and below the midpoint.
% Data from each group is randomly sampled and used to calculate a
% distribution of amplitudes.
%    [value,sigma]=estimateAmplitude(object);
% The output "value" is the median amplitude obtained from 1000 iterations.
% The output "sigma" is an estimate of the standard deviation based
% on the 0.45-0.55 quantile range.  These estimates are most relevant to
% quasi-square wave signals.
%
% Optional parameters are passed by name/value pair.
%    [...]=estimateAmplitude(object,name,value,...);
% Valid options include:
%    -'Iterations', which controls the number of statistical samples.
%    -'Range', which controls the quantile range used for uncertainty
%    estimation.  Values should be specified as [low high].  The low value
%    must be larger than 0 and less than 0.50 (the median).  The high value
%    must be larger than 0.50 and less than 1.
%    -'ShotPlot', which controls if the the quantile plot should be
%    generated in a new figure.  The default value is 'off'.
%
% See also Signal 
%
function [value,sigma]=estimateAmplitude(object,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');

option.Iterations=1000;
option.Range=[0.45 0.55];
option.ShowPlot='off';
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'iterations'
            assert(SMASH.General.testNumber(value,'positive','integer','notzero'),...
                'ERROR: invalid number of iterations');
            option.Iterations=value;
        case 'range'
            ERRMSG='ERROR: invalid quantile range';
            assert(isnumeric(value) && (numel(value) == 2) ...
                && all(value > 0) && all(value < 1),ERRMSG);
            value=sort(value);
            assert((value(2) > value(1)) && (value(1) < 0.50) ...
                && (value(2) > 0.50),ERRMSG)
            option.Range=sort(value);
        case 'showplot'
            assert(strcmpi(value,'on') || strcmpi(value,'off'),...
                'ERROR: show plot must be ''on'' or ''off''');
            option.ShowPlot=lower(value);
        otherwise
            error('ERROR: "%s" is not a valid option',name);
    end
end

% bootstrap analysis
data=object.Data;
threshold=(max(data)+min(data))/2;
index=(data >= threshold);
above=data(index);
below=data(~index);
ka=randi(numel(above),[option.Iterations 1]);
kb=randi(numel(below),[option.Iterations 1]);
change=above(ka)-below(kb);

% quantile curve
x=linspace(0,1,option.Iterations);
y=sort(change);
value=interp1(x,y,0.50);

keep=(x >= option.Range(1)) & (x <= option.Range(2));
param=polyfit(x(keep),y(keep),2);
sigma=polyval(polyder(param),0.5)/sqrt(2*pi); % scaling based on probit function

%%
if strcmp(option.ShowPlot,'off')
    return
end
figure();
plot(x,y,'k',x(keep),polyval(param,x(keep)),'r',0.50,value,'ro');
xlabel('Quantile');
ylabel('Amplitude');
label=sprintf('Curve generated from %d iterations',option.Iterations);
title(label);

end