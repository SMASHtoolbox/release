%% define data
x=[4.15 3.13 15.00 11.67 37.00 873.32 54.43 2.60 22.97 107.13 1144.53 ...
   275.63 47.00 14309.00 54.47 3.30 3.15 183.68 3986.33 336.62 3921.80 ...
   362.53 978.83 367.98 497.67 5801.53 198.83];

y=[1.01 1.00 0.91 0.94 0.83 0.66 0.81 0.98 0.85 0.77 0.62 0.72 0.81 0.22 ...
   0.81 1.00 0.98 0.73 0.45 0.74 0.46 0.70 0.64 0.70 0.70 0.39 0.73];

%% set up Curve object with three basis functions
object=SMASH.CurveFit.Curve([x(:) y(:)]);

object=add(object,@(p,x) ones(size(x)),[]);

exponential=@(p,x) exp(-x/p);
object=add(object,exponential,50,'lower',0,'upper',100);
object=add(object,exponential,1000,'lower',100,'upper',10e3);

%% adjust fit parameters
object=fit(object);
summarize(object);
report=summarize(object);

%% display results
xfit=linspace(min(x),max(x),10e3);

plot(x,y,'o',xfit,evaluate(object,xfit));
xlabel(' time (minutes)')
ylabel(' IP fading factor')
label='f(x) =';
label=sprintf('%s %5.3f +',label,report(1).Scale(1));
label=sprintf('%s + %5.3f exp(-x/%5.3f)',...
    label,report(2).Scale(1),report(2).Parameter(1));
label=sprintf('%s + %5.3f exp(-x/%5.3f)',...
    label,report(3).Scale(1),report(3).Parameter(1));
title(label)

set(gca,'XScale','log');
figure(gcf);

%% uncertainty analysis
report=analyze(object,[x(:) y(:)],10e3);
confidence(report)