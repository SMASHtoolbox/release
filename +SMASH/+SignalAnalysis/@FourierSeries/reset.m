function object=reset(object,x,y,order,points)

% manage input

% determine coefficients
N=numel(x);
L=

basis=ones(N,1+2*order);
for n=1:N
    column=2*n;
    basis(:,column)=cos(
end

end