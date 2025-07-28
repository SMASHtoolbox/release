% UNDER CONSTRUCTION
%
%
function region=guessROI(object,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
option.PowerThreshold=1e-2;
option.NumberPoints=20;
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'powerthreshold'
            assert(isscalar(value) && isnumeric(value),...
                'ERROR: invalid power threshold');
            option.PowerThreshold=abs(value);
        case 'numberpoints'
            assert(isscalar(value) && isnumeric(value),...
                'ERROR: invalid number of points');
            option.NumberPoints=round(abs(value));
        otherwise
            error('ERROR: invalid option');
    end
end

% scan spectrogram
object.ShowNegativeFrequencies=false;

data=object.Spectrogram{1};
time=data.Grid1;
N=numel(time);
velocity=data.Grid2;
width=0.10*abs(velocity(end)-velocity(1));
power=data.Data;
result=nan(2,N);
local=@(P) analyzeSpectrum(velocity,P);
if SMASH.System.isParallel
    parfor n=1:N
        result(:,n)=local(power(:,n));
    end
else
    for n=1:N
       result(:,n)=local(power(:,n));
    end
end
result=transpose(result);

% process results
amplitude=result(:,2);
amplitude=amplitude/max(amplitude);
pass=(amplitude >= option.PowerThreshold);
start=find(pass,1,'first');
stop=find(pass,1,'last');
time=time(start:stop);
velocity=result(start:stop,1);

change=abs(diff(velocity));
change(2:end+1)=change;
change(1)=0;
change=cumsum(change);
change=change/change(end);

tref=object.ReferenceSelection;
k=(time >= tref(1)) & (time <= tref(2));
x=time(k);
x0=x(1);
Lx=x(end)-x(1);
x=(x-x0)/Lx;
y=change(k);
param=polyfit(x(:),y(:),1);
change=change(:)-polyval(param,(time(:)-x0)/Lx);

y=linspace(0,max(change),option.NumberPoints);
t=nan(option.NumberPoints,1);
for k=1:option.NumberPoints
    index=find(change >= y(k),1,'first');
    t(k)=time(index);
end
v=interp1(time,velocity,t);

% generate table
table=[t(:) v(:)];
table(:,end+1)=width;
for row=2:(size(table,1)-1)
    width=table(row+1,2)-table(row-1,2);
    table(row,3)=max(table(row,3),width);
end
table(:,3)=max(table(:,3));

region=SMASH.ROI.Curve('x');
region=define(region,table);
region.DefaultWidth=max(table(:,3));

end


function result=analyzeSpectrum(velocity,power)

result=nan(2,1);
report=SMASH.Velocimetry.PDV.findPeak([velocity(:) power(:)]);
result(1)=report.Location;
result(2)=report.Amplitude;

end