% locate Locate step wedge regions
%
% This method locates constant regions in step wedge measurement.  The
% number of regions is determined by the StepLevels and StepOffsets
% settings.  Step transitions are determined by numerical differentiation,
% which is controlled by the DerivativeParams setting.  HorizontalMargin
% and VerticalMargin settings specify fractional spacing between the step
% transitions and the corresponding region boundaries.
%
% Calling the method with an output:
%     >> object=locate(object);
% updates the RegionTable result.  Calling the method with no output:
%     >> locate(object);
% displays the measurement with regions marked by dashed rectangles.
%
% NOTE: this method is automatically called by the analyze method.  Users
% generally do *not* need to call the method directly except for
% troubleshooting.
%
% See also StepWedge, view
%

%
% created August 26, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function varargout=locate(object)

% horizontal edges
temp=mean(object.Measurement,'Grid2');
deriv=differentiate(temp,object.Settings.DerivativeParams);
x=deriv.Grid;
z=deriv.Data.^2;
z=z/max(z);

N=numel(object.Settings.StepLevels)-1;
xedge=findPeaks(x,z,N);
%xedge=findPeaks2(x,z,N); % CHANGE THIS WHEN READY!
left=[object.Measurement.Grid1(1) xedge];
right=[xedge object.Measurement.Grid1(end)];

% vertical edges
M=numel(object.Settings.StepOffsets)-1;
top=nan(M+1,N+1);
bottom=nan(M+1,N+1);
for n=1:(N+1)
    temp=mean(object.Measurement,'Grid1',[left(n) right(n)]);
    deriv=differentiate(temp,object.Settings.DerivativeParams);
    y=deriv.Grid;
    z=deriv.Data.^2;
    z=z/max(z);
    yedge=findPeaks(y,z,M);
    top(1,n)=object.Measurement.Grid2(1);
    top(2:end,n)=yedge(:);
    bottom(1:end-1,n)=yedge(:);
    bottom(end,n)=object.Measurement.Grid2(end);
end

% construct region table
L=(M+1)*(N+1);
object.Results.RegionTable=nan(L,4);
k=1;
for n=1:(N+1);
    for m=1:(M+1)
        x0=left(n);
        y0=top(m,n);
        Lx=right(n)-left(n);
        Ly=bottom(m,n)-top(m,n); % image convention makes this backwards!
        correction=Lx*object.Settings.HorizontalMargin;
        x0=x0+correction;
        Lx=Lx-2*correction;
        correction=Ly*object.Settings.VerticalMargin;
        y0=y0+correction;
        Ly=Ly-2*correction;
        object.Results.RegionTable(k,:)=[x0 y0 Lx Ly];
        k=k+1;
    end
end

% manage output
if nargout==0
    view(object);
    for k=1:L
        rectangle('Position',object.Results.RegionTable(k,:),'EdgeColor','k','LineStyle','-');
        rectangle('Position',object.Results.RegionTable(k,:),'EdgeColor','w','LineStyle','--');
    end
else
    varargout{1}=object;
end

end

function location=findPeaks(x,z,N)

previous=1;
threshold=0.50;
test2=deal(false(size(z)));
iteration=1;
while true
    test1=(z>=threshold);
    test2(2:end)=~test1(1:end-1);
    found=sum(test1 & test2);
    if found==N
        break
    elseif iteration>100
        error('ERROR: unable to locate region edges');
    elseif found<N
        new=threshold/2;
    else
        new=(previous+threshold)/2;
    end
    previous=threshold;
    threshold=new;
    iteration=iteration+1;
end

location=nan(1,N);
for n=1:N
    % find edges of the n-th peak
    start=find(test1,1,'first');    
    test1=test1(start:end);
    x=x(start:end);
    z=z(start:end);
    stop=find(~test1,1,'first');
    % determine the centroid of the n-th peak
    xn=x(1:stop-1);
    zn=z(1:stop-1);
    location(n)=sum(xn.*zn)/sum(zn);
    % prepare for the next peak
    test1=test1(stop:end);
    x=x(stop:end);
    z=z(stop:end);
end

end

function location=findPeaks2(x,z,N)

% initial preparation
x1=min(x);
x2=max(x);

% estimate peak spacing
temp=SMASH.SignalAnalysis.Signal(x,z);
[f,P]=fft(temp,'NumberFrequencies',10e3);
guess=(N+1)/(x2-x1);
fb=[0.75 1.75]*guess;
index=(f>fb(1)) & (f<fb(2));
f=f(index);
P=P(index);
P=P/max(P);
index=(P>=0.50);
f=f(index);
P=P(index);
f0=trapz(f,f.*P)/trapz(f,P);
spacing=1/f0;

% find the strongest peak near the center
x0=mean(x);
left=x0-spacing;
right=x0+spacing;
index=(x>=left) & (x<=right);
xc=x(index);
zc=z(index);
[~,index]=max(zc);
x0=xc(index);

% estimate peak centers
guess=x0+(-N:N)*spacing;
keep=((guess)>x1) & (guess<x2);
guess=guess(keep);

% YOU ARE HERE
%keyboard



end