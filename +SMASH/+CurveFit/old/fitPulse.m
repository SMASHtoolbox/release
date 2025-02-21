% UNDER CONSTRUCTION
% fitPulse Fit finite pulse
%
% This method fits a pulse that rises and falls over a finite range.
%   object=fitPulse(data);
%   object=fitPulse(data,'symmetric');
%

function object=fitPulse(data,mode)

% manage input
assert(isnumeric(data) && ismatrix(data) && (size(data,2) == 2),...
    'ERROR: invalid data array');
Npoint=size(data,1);
% some error checking needed here
x=data(:,1);
y=data(:,2);

if (nargin < 2) || isempty(mode)
    mode='symmetric';
else
    assert(ischar(mode),'ERROR: invalid fig mode');
end

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
ymid=mean(y);
flag=(y < ymid);
if flag(1)
    flag=(~flag);
    index(1)=find(flag,1,'first');
    index(2)=find(flag,1,'last');
else        
    index(1)=find(flag,1,'first');
    index(2)=find(flag,1,'last');
end
location=x(index);
location=reshape(location,1,[]);
width=(x(end)-x(1))/(numel(x)-1);

% set up fit object
object=SMASH.CurveFit.Curve([x y]);
object=add(object,@(~,x) ones(size(x)),[]);
switch lower(mode)
    case 'symmetric'
        object=add(object,@symmetric,[location width]);
    case 'nonsymmetric'
        object=add(object,@nonsymmetric,[location width width]);
    otherwise
        error('ERROR: invalid fit mode');
end
    function out=symmetric(q,x)
        out=(tanh((x-q(1))/q(3))+1)/2-(tanh((x-q(2))/q(3))+1)/2;
    end
    function out=nonsymmetric(q,x)
        out=(tanh((x-q(1))/q(3))+1)/2-(tanh((x-q(2))/q(4))+1)/2;
    end
temp=summarize(object);
bound=temp(2).Bound(1,:);
bound(3:end)=width;
object=edit(object,2,'lower',bound);

% optimize parameters
object=fit(object);

end