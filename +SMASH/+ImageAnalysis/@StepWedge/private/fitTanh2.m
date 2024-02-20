function result=fitTanh2(x,y,options)

% manage input
N=numel(x);
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

% perform fit
x1=[];
L1=[];
x2n=[];
L2n=[];
B2n=[];
matrix=ones(N,2);
vector=[];
fit=[];
    function chi2=residual(param)
        x1=param(1);
        L1=param(2);
        x2n=param(3);
        L2n=param(4);
        B2n=param(5);
        xu=(x-x1)/L1;        
        arg=sign(xu-x2n).*(exp(abs(xu-x2n)./(L2n+B2n.*sign(xu-x2n)))-1);        
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
guess=[xmean Lx/4 0 1 0];

result=fminsearch(@residual,guess,options);
final=sqrt(residual(result));
fprintf('Average error: %.2g\n',final);

%%
%subplot(2,1,1);
plot(x,y,'o',x,fit,'k');
xlabel('x=log_{10} (exposure)');
ylabel('Step density');

end