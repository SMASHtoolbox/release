%%

%% 
close all
clear
clc

%% generate data
x=linspace(0,10,100);

baseline=0.10;
A=[1 2 3];
x0=[2 4 8];
sigma=[0.1 0.2 0.3];

y=zeros(size(x));
for k=1:numel(A)
    y=y+A(k)*exp(-(x-x0(k)).^2/(2*sigma(k)^2));
end
y=y+baseline;

y=y+0.1*randn(size(y));

%% setup and use Curve object
object=SMASH.CurveFit.Curve([x(:) y(:)]);

gaussian=SMASH.CurveFit.makePeak('gaussian');
background=SMASH.CurveFit.makeBackground('constant');

object=add(object,background,[]);

object=add(object,gaussian,[2.1 0.075],...
    'lower',[1 0.05],'upper',[3 0.2]);

object=add(object,gaussian,[3.9 0.225],...
    'lower',[3 0.1],'upper',[5 0.3]);

object=add(object,gaussian,[7.5 0.25],...
    'lower',[7 0.2],'upper',[9 0.4]);

%options=optimset('Display','iter');
options=optimset();
object=fit(object,options);

summarize(object);
report=summarize(object);
view(object);

label=sprintf('x0=%.3f\nsigma=%.3f',...
    report(2).Parameter(1),report(2).Parameter(2));
text(report(2).Parameter(1),4,label,...
    'HorizontalAlignment','center');

label=sprintf('x0=%.3f\nsigma=%.3f',...
    report(3).Parameter(1),report(3).Parameter(2));
text(report(3).Parameter(1),4,label,...
    'HorizontalAlignment','center');

label=sprintf('x0=%.3f\nsigma=%.3f',...
    report(4).Parameter(1),report(4).Parameter(2));
text(report(4).Parameter(1),4,label,...
    'HorizontalAlignment','center');

yb=ylim;
yb(2)=5;
ylim(yb);

%%
report=analyze(object,[x(:) y(:)],10e3);
confidence(report);