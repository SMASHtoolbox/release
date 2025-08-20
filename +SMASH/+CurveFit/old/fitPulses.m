function object=fitPulses(data)

% manage input
assert(isnumeric(data) && ismatrix(data) && (size(data,2) == 2),...
    'ERROR: invalid data array');
Npoint=size(data,1);
% some error checking needed here
x=data(:,1);
y=data(:,2);

% prepare data
persistent source
if isempty(source)
    source=SMASH.SignalAnalysis.Signal(x,y);
else
    source=reset(source,x,y);
end
object=regrid(source);
x=object.Grid;
y=object.Data;

% estimate parameters
temp=fft(object,'RemoveDC',true,'NumberFrequencies',1e6);
[~,index]=max(temp.Data);
f0=temp.Grid(index);
period=1/f0;

% set up fit object
object=SMASH.CurveFit.Curve([x y]);
object=add(object,@(~,x) ones(size(x)),[]);
guess=[0 period/2 period];
object=add(object,@myfunc,guess);

% optimize parameters
object=fit(object);

end

function y=myfunc(p,x)

period=p(3);
width=p(2);
start=x(1)-period+rem(abs(p(1)),period);

y=zeros(size(x));
arg=rem(x-start,period);
y(arg <= width) = 1;

end