function y=SquareStep(param,x)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');

assert(isnumeric(param),'ERROR: invalid parameter array');
assert(numel(param)==1,...
    'ERROR: this function requires one parameter');
x1=param(1);

y=zeros(size(x));
index=(x>=x1);
y(index)=1;

end