function y=LorentzianPeak(param,x)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');

assert(isnumeric(param),'ERROR: invalid parameter array');
assert(numel(param)==2,...
    'ERROR: this function requires two parameters');
x0=param(1);
Lx=param(2);

assert(isnumeric(x),'ERROR: invalid x array');

% calculations
y=(x-x0)/Lx;
y=1./(1+y.^2);

end