function object=fitPulse(object,target,fraction)

% manage input
if (nargin < 2) || isempty(target)
    target=object;
    T=object.Grid(end)-target.Grid(1);
    target.Period=2*T;
    target.Shift=0.25;
    target.Rise=0.01*T;
    target.Fall=0.1*T;
    target=target.Output;
    A=(max(target.Data)-min(target.Data))/2;
    target=target+0.10*A*randn(size(target.Data));
else
    assert(isa(target,'SMASH.SignalAnalysis.Signal'),...
        'ERROR: invalid target signal');
    object.Grid=target.Grid;
    T=target.Grid(end)-target.Grid(1);
end

if (nargin < 3) || isempty(fraction)
    fraction=0.10;
else
    assert(SMASH.General.testNumber(fraction,'positive','notzero') && (fraction < 1),...
        'ERROR: invalid smooth fraction');
end

% estimate rise/fall locations
M=round(fraction*numel(target.Grid));
temp=differentiate(target,[1 M]);
[~,index(1)]=max(temp.Data);
[~,index(2)]=min(temp.Data);
index=sort(index);
edge=target.Grid(index)-target.Grid(1);

model=SMASH.CurveFit.Curve([target.Grid target.Data]);
model=add(model,@(~,x) ones(size(x)),[]);

object.Period=2*T;
object.Rise=2*T/(numel(object.Grid)-1);
object.Fall=object.Rise;
model=add(model,@basis,[edge(1) eps diff(edge) eps],...
    'lower',[0 0 0 0],'upper',[T T T T]);
    function y=basis(p,x)
        object.Grid=x;
        object.Shift=p(1);
        object.Rise=p(2);       
        object.Hold=p(3);
        object.Fall=p(4);
        y=object.Output.Data;
    end
model=fit(model);

end