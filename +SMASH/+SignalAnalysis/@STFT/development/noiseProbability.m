function result=noiseProbability(x,y,sigma)

% determine summation window
dx=abs(x(end)-x(1))/(numel(x)-1);
M=2*round(sigma/dx)+1;

kernel=ones(M,1);
ysum=conv2(y(:),kernel,'same');
ysum=max(ysum);


% sum noise model
sigma=sqrt(M)*sigma;
result=erfc(abs(ysum)/sqrt(2)/sigma);

end