% findPulse Find pulse on a flat background
%
% This function finds a signal pulse on flat background.
%    [center,width]=findPulse(source);
% The input "source" can be a Signal object, a two-column array [x y], or a
% column/row vector.  Outputs "center" and "width" are based on data near
% the peak of w=(y-median(y)).^2.  Omitting these outputs:
%    findPulse(source);
% plots the data, marking the center with a vertical line and showing the
% center/width in the title.
%
% Weighted calculations are based on the locations where w >= 0.50 by
% default.  Passing a second argument:
%    [...]=findPulse(source,threshold);
% modifies the analysis.  The input "threshold" must be greater than zero
% and less that one.  Small thresholds use more locations in the analysis,
% which can bias the center for skewed peaks.  Large thresholds use fewer
% locatios in the analysis, which may coarsen the center result.
%
% See also SMASH.SignalAnalysis, Signal
%
function varargout=findPulse(source,threshold)

% manage input
assert(nargin > 0,'ERROR: insufficient input');
if isobject(source)  
    assert(isa(source,'SMASH.SignalAnalysis.Signal'),...
        'ERROR: invalid source object');
    [x,y]=limit(source);    
else
    assert(isnumeric(source) && ismatrix(source),...
        'ERROR: invalid source array');
    [rows,columns]=size(source);
    if (rows == 1) || (columns == 1)
        y=source(:);
        x=tranpose(1:numel(y));    
    else
        assert(columns == 2,'ERROR:  invalid source array');
        x=source(:,1);
        y=source(:,2);
    end
end

assert(all(isfinite(x)),'ERROR: all grid points must be finite');
if ~all(isfinite(y))
    swap=~isfinite(y);
    y(swap)=0;   
end

if (nargin < 2) || isempty(threshold)
    threshold=0.50;
else
    assert(isnumeric(threshold) && isscalar(threshold) ...
        && (threshold > 0) && (threshold < 1),...
        'ERROR: threshold must be a number between 0 and 1');   
end

% iterative analysis
y=y-median(y);
y2=y.^2;
y2=y2/max(y2);

keep=(y2 >= threshold);
y2k=y2(keep);
xk=x(keep);
weight=y2k/sum(y2k);
center=sum(xk.*weight);
width=sqrt(sum((xk-center).^2.*weight));

% manage output
if nargout > 0
    varargout{1}=center;
    varargout{2}=width;
    return
end

figure();
plot(x,y);
xline(center);

label=sprintf('Location = %#+g, width = %#g',center,width);
title(label);

end