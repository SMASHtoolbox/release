function y=LinearBackground(slope,x)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');
assert(SMASH.General.testNumber(order,'positive','integer'),...
    'ERROR: invalid order parameter')

param=zeros(1,order+1);
param(1)=1;
y=polyval(param,x);

end