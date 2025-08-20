function new=fit(object,target,Npulse)

% manage input
if (nargin < 2) || isempty(target)
    target=object;
    T=object.Grid(end)-target.Grid(1);
    object.Period=T/2;
    target.Shift=T*(2*rand(1)-1);
    target.Rise=0.01*T;
    target.Fall=0.1*T;
    target=target.Output;
    A=(max(target.Data)-min(target.Data))/2;
    target=target+0.10*A*randn(size(target.Data));
else
    assert(isa(target,'SMASH.SignalAnalysis.Signal'),...
        'ERROR: invalid target signal');
end

if (nargin < 3) || isempty(Npulse)
    Npulse=inf;
end

% prepare for fit
new=object;
new.Grid=target.Grid;
new.Amplitude=1;
new.Baseline=0;

temp=fft(target,'RemoveDC',true,'NumberFrequencies',10e3);
[~,index]=max(temp.Data);
f0=temp.Grid(index);
period=1/f0;

temp=SMASH.CurveFit.Curve([target.Grid target.Data]);
temp=add(temp,@(~,x) ones(size(x)),[]);
guess=[0 period/2 0];
temp=add(temp,@myfunc,guess);
    function y=myfunc(p,~)
        new.Parameter(1:3)=p;
        y=generate(new);
        y=y.Data;
    end
temp=fit(temp);

end