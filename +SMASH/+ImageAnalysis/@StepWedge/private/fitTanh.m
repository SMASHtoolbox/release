function result=fitTanh(x,y,order,options)

% manage input
if (nargin<3) || isempty(order)
    order=2;
end

if (nargin<4) || isempty(options)
    options=optimset('MaxFunEvals',2000);
end

N=numel(x);
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

% perform fit
x0=[];
L=[];
gamma=[];
beta=[];
matrix=ones(N,2);
vector=[];
fit=[];
    function chi2=residual(param)
        x0=param(1);
        L=param(2);
        %gamma=param(end:-1:3); % odd terms
        %gamma(end+1,:)=0; % even terms
        %gamma=transpose(gamma(:));
        param=param(3:end);
        gamma1=param(1:order);
        gamma1(end+1)=1;
        gamma2=param(order+1:end);
        gamma2(end+1)=1;
        beta1=conv(gamma1,gamma1);
        beta1=polyint(beta1);
        beta2=conv(gamma2,gamma2);
        beta2=polyint(beta2);
        index=(x<=x0);
        arg=nan(size(x));
        arg(index)=polyval(beta1,(x(index)-x0)/L)-polyval(beta1,0);
        index=(x>0);
        arg(index)=polyval(beta2,(x(index)-x0)/L)-polyval(beta2,0);        
        %gamma=param(end:-1:3);
        %gamma(end+1)=1;
        %beta=conv(gamma,gamma); % polynomial multiplication        
        %beta=polyint(beta);
        %arg=polyval(beta,(x-x0)/L)-polyval(beta,0);       
        matrix(:,2)=tanh(arg);
        vector=matrix\y;
        fit=matrix*vector;
        chi2=(y-fit).^2;
        chi2=sum(chi2)/N;
    end
xmin=min(x);
xmax=max(x);
Lx=xmax-xmin;
xmean=(xmin+xmax)/2;
guess=[xmean Lx/4];
guess(end+1:end+2*order)=0;

result=fminsearch(@residual,guess,options);
final=sqrt(residual(result));
fprintf('Average error: %.2g\n',final);

%%
%xf=linspace(xmin,xmax,1000);
%arg=polyval(beta,(xf-x0)/L)-polyval(beta,0);   
%yf=vector(1)+vector(2)*tanh(arg);
%subplot(2,1,1);
%plot(x,y,'o',xf,yf,'k');
plot(x,y,'o',x,fit);
xlabel('x=log_{10} (exposure)');
ylabel('Step density');

%subplot(2,1,2);
%plot(xf,arg,'k',xf,xf,'r--');
%xlabel('x');
%ylabel('u(x)');
%ylim(xlim);

end