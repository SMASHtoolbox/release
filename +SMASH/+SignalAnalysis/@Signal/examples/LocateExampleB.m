%% create signal
t=linspace(0,1,100);
s=zeros(size(t));
t1=0.4;
t2=0.6;
k=(t >= t1);
s(k)= (t(k)-t1)/(t2-t1);
k=(t >= t2);
s(k)=1;

object=SMASH.SignalAnalysis.Signal(t,s);
object=object+0.10*randn([numel(t) 1]);
locate(object,'step');

%% full analysis
[report,curve]=locate(object,'step');
disp(report);

temp=analyze(curve);
summarize(temp);
confidence(temp);