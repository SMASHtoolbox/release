% locate Locate scan peak
%
% This method locates peaks in a LUNA scan using a finite time width.
%     [time,RL]=locate(object,width);
% The "time" output is the integration center of maximum area for the
% specified width.  The "RL" output is the estimated return loss (in dB) of
% this integration.
%
% By default, peak analysis spans the entire time range of the LUNA scan.
% Passing a third input restricts analysis to a specified range.
%     [time,RL]=locate(object,width,[tmin tmax]);
% Infinite range values, such as [0 inf], are permitted.
%
% Calling this method with no outputs:
%     >> locate(...);
% generates a plot of the peak region.  Time and return loss results are
% displayed in the title of this plot.
%
% See also LUNA
%

%
% created April 30, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=locate(object,width,region)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

assert(isnumeric(width) && isscalar(width) && width>0,...
    'ERROR: invalid width');

if (nargin<3) || isempty(region)
    region=[0 max(object.Time)];
end
assert(isnumeric(region) && numel(region)==2,...
    'ERROR: invalid region');
region=sort(region);

% perform local search
x=object.Time;
y=object.LinearAmplitude;
index=(x>=region(1)) & (x<=region(2));
x=x(index);
y=y(index);

dx=(x(end)-x(1))/(numel(x)-1);
L=ceil(width/dx);
kernel=ones(L,1);
z=conv2(y,kernel,'same');
[~,k]=max(z);
time=x(k);

k=abs(x-time)<=(width/2);
area=trapz(x(k),y(k));
% factor of two correction may be needed to account for round trip timing!
c0=299792458/object.FileHeader.GroupIndex; % m/s
c0=c0*1e3/1e9; % mm/ns
area=c0*area;
RL=-10*log10(area);

% manage output
if nargout==0
    view(object);
    L=3*width;
    xlim(time+[-1 +1]*L/2)
    label=sprintf('t0=%.3f ns, RL=%.0f dB',time,RL);
    title(label);
    line(repmat(time,[1 2]),ylim,'Color','k','LineStyle','--');
else
    varargout{1}=time;
    %varargout{2}=area;
    varargout{2}=RL;
end

end