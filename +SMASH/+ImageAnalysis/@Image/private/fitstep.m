function [center,width,jump]=fitstep(x,y)

% guess values
x0=mean(x);
L=(max(x)-min(x))/4;

% array set up
x=x(:);
y=y(:);
Q=ones(numel(x),2);
    function [chi2,b,fit]=residual(param)
        x0=param(1);
        L=param(2);
        Q(:,2)=tanh((x-x0)/L);
        b=Q\y;
        fit=Q*b;
        chi2=(y-fit).^2;
        chi2=mean(chi2);
    end
options=optimset;
param=fminsearch(@residual,[x0 L],options);

center=param(1);
width=param(2);
[~,b]=residual(param);
jump=2*b(2);

end