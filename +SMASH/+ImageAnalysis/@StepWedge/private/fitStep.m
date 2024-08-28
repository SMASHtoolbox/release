function result=fitStep(x,y,order,options)

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
        gamma=param(3:end);    
        gamma(end+1)=1;
        beta=conv(gamma,gamma);       
        beta=polyint(beta);       
        arg=polyval(beta,(x-x0)/L)-polyval(beta,0);            
        matrix(:,2)=arg;
        %matrix(:,2)=tanh(arg);        
        %arg=(matrix(:,2)-min(matrix(:,2)))/(max(matrix(:,2)-min(matrix(:,2))));
        %index=(arg>0.975);
        %matrix(index,2)=min(matrix(index,2));
        %index=(arg<0.025);
        %matrix(index,2)=max(matrix(index,2));
        %matrix(:,2)=arg;
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
ha(1)=subplot(2,1,1);
plot(x,y,'o',x,fit);
xlabel('x=log_{10} (exposure)');
ylabel('Step density');

ha(2)=subplot(2,1,2);
plot(x,polyval(conv(gamma,gamma),(x-x0)/L));


linkaxes(ha,'x');

end