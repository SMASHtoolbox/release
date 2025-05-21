% locate Locate feature in an object
%
% This method locates features in a Signal object.
%    report=locate(object,shape);
% Supported shapes include a Gaussian 'peak' (default) and and error
% function 'step'.  The output "report" is a structure of best fit
% parameters.
%
% Requesting a second output:
%    [report,curve]=locate(object,shape);
% returns a Curve object that fits the local feature.  Uncertainty analysis
% for the fit can be performed with this object.
%
% NOTE: signal cropping and/or limiting can significantly improve the speed
% and reliability of this method.
%
% Examples:
%    <a href="matlab:SMASH.System.showExample('LocateExampleA','+SMASH/+SignalAnalysis/@Signal')">Peak location</a>
%    <a href="matlab:SMASH.System.showExample('LocateExampleB','+SMASH/+SignalAnalysis/@Signal')">Step location</a>
%
% See also Signal, compare, crop, limit, SMASH.CurveFit.Curve
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised May 1, 2018 by Daniel Dolan
%    -invoked Curve class instead of local solvers
%
function varargout=locate(object,shape)

% manage input
if (nargin<2) || isempty(shape) 
    shape='peak';
else
    assert(ischar(shape),'ERROR: invalid feature shape');
    shape=lower(shape);
end

% apply curvefit
[x,y]=limit(object);
center=(x(1)+x(end))/2;
width=abs(x(end)-x(1))/4;
guess=[center width];
curve=SMASH.CurveFit.Curve([x(:) y(:)]);
switch shape
    case 'peak'
        curve=add(curve,@peak,guess);
    case 'step'
        curve=add(curve,@step,guess);
    otherwise
        error('ERROR: %s is an invalid feature shape');
end
    function out=peak(p,x)
        out=exp(-(x-p(1)).^2/(2*p(2)^2));
    end
    function out=step(p,x)
        out=(1+erf((x-p(1))/p(2)))/2;
    end

curve=add(curve,@(p,x) ones(size(x)),[]);

try
    curve=fit(curve);
catch ME
    throwAsCalle(ME);
end

% handle output
report.Location=curve.Parameter{1}(1);
report.Width=curve.Parameter{1}(2);
if nargout==0
    view(curve);
    %line(x,report.Fit,'Color','k','LineStyle','--');
    label=sprintf('Location = %#+g',report.Location);
    title(label);
else
    varargout{1}=report;
    varargout{2}=curve;
end

end