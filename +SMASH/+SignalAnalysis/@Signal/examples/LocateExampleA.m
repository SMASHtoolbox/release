%% create signal
t=linspace(0,1,100);
object=SMASH.SignalAnalysis.Signal(t,exp(-(t-0.5).^2/(2*0.05^2)));
object=object+0.10*randn([numel(t) 1]);
locate(object);

%% full analysis
[report,curve]=locate(object);
disp(report);

temp=analyze(curve);
summarize(temp);
confidence(temp);