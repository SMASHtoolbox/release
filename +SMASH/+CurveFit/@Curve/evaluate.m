% evaluate Evaluate curve
%
% This method evaluates a Curve object at specified locations:
%     y=evaluate(object); % stored evaluation grid
%     y=evaluate(object,x); % specify evaluation grid
% using the current basis parameters and scaling factors.
%
% See also Curve, view
%

%
% created December 1, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function [y,basis,ScaledBasis]=evaluate(object,x)

% manage input
if (nargin < 2) || isempty(x)
    x=object.EvaluationGrid;   
end

% perform evaluation
x=x(:);
M=numel(x);

N=numel(object.Basis);
basis=zeros(M,N);
ScaledBasis=basis;
for n=1:N
    basis(:,n)=feval(object.Basis{n},object.Parameter{n},x);
    ScaledBasis(:,n)=object.Scale{n}*basis(:,n);
end
y=sum(ScaledBasis,2);

end