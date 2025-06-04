% findLevels Find steady levels
%
% This methods finds steady levels in signal data, i.e. regions of
% relatively constant or repeating values.  
%    report=findLevels(object,levels);
% The input "levels" indicates the number of levels to be found; this can
% be any number >= 2 (the default value).  The output "report" is a
% structure containing information, such as the median and standard
% deviation, for each level.  Residual and edge values (see below) are also
% contained in that structure.
%
% Level analysis is based on N-1 quantile edges, which define transitions
% between N levels.  For example, a two-level anaysis separates data values
% by a single quantile edge: the first level is determined by values below
% that quantile and the second level is determined by values above that
% quantile.  Edge values are determined by nonlinear optimization, starting
% with uniformly-spaced quantile transitions.  Initial values can be
% specified to assist that optimization.
%    report=findLevels(object,levels,guess);
% The input "guess" must have levels-1 unique values between 0 and 1.  
%
% See also Signal
%
function varargout=findLevels(object,levels,guess)

% manage input
if (nargin < 2) || isempty(levels)
    levels=2;
else
    assert(isnumeric(levels) && isscalar(levels) && (levels >= 2),...
        'ERROR: invalid number of levels');
    levels=round(levels);
end

if (nargin < 3) || isempty(guess)
    guess=linspace(0,1,levels+1);
    guess=guess(2:end-1);
else
    guess=unique(guess);
    assert(isnumeric(guess) && numel(guess) == levels-1,...
        'ERROR: invalid quantile guess');
    assert(all(guess >= 0) && all(guess <= 1),...
        'ERROR: quatile guesses must be between 0 and 1');
end

%
data=object.Data;
data=data(isfinite(data));
assert(~isempty(data),'ERROR: at least some signal data must be finite');

left=zeros(1,levels);
right=ones(1,levels);
    function updateBounds(param)        
        for nn=1:levels
            if nn > 1
                left(nn)=param(nn-1);                
            end
            if nn < levels
                right(nn)=param(nn);
            end
            
        end
    end

Q=sort(data);
x=linspace(0,1,numel(data));

err=nan(size(x));
    function chi2=residual(xb)
        updateBounds(xb);        
        for nn=1:levels            
            keep=(x >= left(nn)) & (x <= right(nn));
            temp=Q(keep);
            err(keep)=temp-median(temp);            
        end
        chi2=mean(err.^2);
    end
edge=fminsearch(@residual,guess);

value=nan(1,levels);
deviation=nan(1,levels);
for n=1:levels
    keep=(x >= left(n)) & (x <= right(n));
    %value(n)=median(Q(keep));
    %deviation(n)=std(Q(keep));
    [mu,sigma]=SMASH.Statistics.TNstats(Q(keep));
    value(n)=mu;
    deviation(n)=sigma;
end

if nargout > 0
    report.Value=value;
    report.Deviation=deviation;
    report.Edge=edge;
    report.Guess=guess;
    report.Residual=residual(edge);
    varargout{1}=report;
    return
end

figure();

subplot(3,1,1);
plot(object.Grid,object.Data,'r');
yline(value,'Color','k','LineWidth',1);
xlabel(object.GridLabel);
ylabel(object.DataLabel);
title('Signal levels');

subplot(3,1,2);
histogram(data,'Normalization','pdf',...
    'EdgeColor','none','FaceColor','r','FaceAlpha',1);
xline(value,'Color','k','LineWidth',1);
xlabel('Value');
ylabel('Probability density');
title('Value distribution');

subplot(3,1,3);
h=plot(x,Q,'r');
set(h,'LineWidth',2);
xlabel('Quantile');
ylabel('Value');
hold on;
for n=1:levels
    errorbar(mean([left(n) right(n)]),value(n),deviation(n),...
        'Color','k','Marker','o','LineWidth',1);
end
hold off;
xline(edge,'Color','k','LineStyle','--','LineWidth',1);
title('Data regions');

end