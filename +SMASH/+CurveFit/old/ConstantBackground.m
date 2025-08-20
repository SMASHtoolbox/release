% ConstantBackground Uniform basis function
%
%
function y=ConstantBackground(~,x)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs');

y=ones(size(x));

end