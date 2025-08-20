function y=ErrorStep(param,x)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');

assert(isnumeric(param),'ERROR: invalid parameter array');
assert(numel(param)==2,...
    'ERROR: this function requires two parameters');
x0=param(1);
L=param(2);

y=(1+erf((x-x0)/L))/2;

end