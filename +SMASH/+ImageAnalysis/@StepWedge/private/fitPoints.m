function varargout=fitPoints(x,y)

% manage input
N=numel(x);
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

% basic fit
fit1=[];
vector=[];
matrix=ones(N,2);
    function chi2=residualA(param)
        x1=param(1);
        L1=param(2);
        arg=(x-x1)/L1;
        matrix(:,2)=tanh(arg);
        vector=matrix\y;
        fit1=matrix*vector;
        chi2=(fit1-y).^2;
        chi2=sum(chi2)/N;
    end
guess=[mean(x) (max(x)-min(x))/4];
result=fminsearch(@residualA,guess);
subplot(2,1,1);
plot(x,y,'ko',x,fit1,'k');

% refined fit
fit2=[];
vector=[];
matrix=ones(N,4);
    function chi2=residualB(param)
        % general step
        x1=param(1);
        L1=param(2);       
        arg=(x-x1)/L1;
        matrix(:,2)=tanh(arg);
        % toe
        x2=param(3);
        L2=param(4);
        arg=(x-x2)/L2;
        %matrix(:,3)=sech(arg);        
        matrix(:,3)=tanh(arg);
        % shoulder
        x3=param(5);
        L3=param(6);
        arg=(x-x3)/L3;
        matrix(:,4)=sech(arg);
        vector=matrix\y;
        fit2=matrix*vector;
        chi2=(fit2-y).^2;
        chi2=sum(chi2)/N;
    end
result(end+1)=result(1)-result(2); % x2
result(end+1)=result(2)/4; % L2
result(end+1)=result(1)+result(2); % x3
result(end+1)=result(2)/4; % L3
result=fminsearch(@residualB,result);
subplot(2,1,1);
line(x,fit2,'Color','r');
subplot(2,1,2);
%plot(x,y-fit2);
plot(x,y-fit1,x,y-fit2);

% manage output
if nargout==0
else
    varargout{1}=result;
end

end