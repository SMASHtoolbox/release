function ys=localArea(x,y,Lx)

% handle input
assert(nargin>=3,'ERROR: insufficient number of inputs');
assert(all(size(x)==size(y)),'ERROR: incompatible (x,y) input');

dx=(x(end)-x(1))/(numel(x)-1);
% requires fixed x spacing!
M=round(Lx/dx);
if rem(M,2)==0
    M=M+1;
end

kernel=repmat(dx,[M 1]);
kernel([1 end])=dx/2;
ys=conv2(y(:),kernel,'same');

ys=reshape(ys,size(x));

end