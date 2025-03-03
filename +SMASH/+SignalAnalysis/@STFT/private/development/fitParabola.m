% UNDER CONSTRUCTION!
function [param,fit]=fitParabola(x,y)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');
if isempty(x)
    x=1:numel(y);
end
assert(numel(x)==numel(y),'ERROR: incompatible data');

% prepare data
x=x(:);
x0=min(x);
Lx=max(x)-x0;
x=(x-x0)/Lx;

y=y(:);
y0=min(y);
Ly=max(y)-y0;
y=(y-y0)/Ly;

% fit polynomial and scale result
param=polyfit(x,y,2);
fit=polyval(param,x);

fit=y0+Ly*fit;
param=param.*[];
param=param*Ly;

%xp=-a(2)/(2*a(1)); % peak location
%LR=abs(1/(2*a(1))); % latus rectum
%result(1)=Lx*xp+x0; % undo normalization
%result(2)=Lx*LR; % undo normalization
%result(3)=Ly*polyval(a,result(1))+y0;

end