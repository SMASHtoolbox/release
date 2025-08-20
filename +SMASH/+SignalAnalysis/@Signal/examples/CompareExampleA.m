% Simple comparison

%% generate signals
time=linspace(-5,5,50);
step=(1+tanh(time/0.5))/2;

A=SMASH.SignalAnalysis.Signal(time,step+0.05*randn(size(time)));
B=SMASH.SignalAnalysis.Signal(time,step+0.05*randn(size(time)));
B=shift(B,1);
B.GraphicOptions.LineColor='r';

%% compare signals
[report,new,model]=compare(A,B,{},[-2 2]);
fprintf('Results:\n');
disp(report);
new.GraphicOptions.LineStyle='--';
view(A);
view(B,gca);
view(new,gca);

result=analyze(model);
summarize(result);
confidence(result,0.90);
