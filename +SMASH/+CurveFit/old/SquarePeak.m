function y=SquarePeak(param,x)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');

assert(isnumeric(param),'ERROR: invalid parameter array');
assert(numel(param)==2,...
    'ERROR: this function requires two parameters');
param=sort(param);
x1=param(1);
x2=param(2);

y=zeros(size(x));
index=(x>=x1) & (x<=x2);
y(index)=1;

end