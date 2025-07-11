function object=fitSinusoid(data)

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

% set up fit object
object=SMASH.CurveFit.Curve([x y]);
object=add(object,@(~,x) ones(size(x)),[]);
object=add(object,@(~,x) cos(2*pi*f0*x),[]);
object=add(object,@(~,x) sin(2*pi*f0*x),[]);
%object=add(object,@myfunc,[f0 0],...
%    'lower',[0.50*f0 -inf],'upper',[1.5*f0 +inf]);
%    function y=myfunc(p,x)
%        y=cos(2*pi*p(1)*x+p(2));
%    end

% optimize parameters
object=fit(object);

end