function findRegions(object)

% horizontal edges
temp=mean(object.Measurement,'Grid2');
deriv=differentiate(temp,object.Settings.DerivativeParams);
x=deriv.Grid;
z=deriv.Data.^2;
z=z/max(z);

N=numel(object.SettingsStepLevels)-1;
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

xedge=nan(1,N);
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
    xedge(n)=sum(xn.*zn)/sum(zn);
    % prepare for the next peak
    test1=test1(stop:end);
    x=x(stop:end);
    z=z(stop:end);
end
left=[object.Measurement.Grid1(1) xedge];
right=[xedge object.Measurement.Grid1(end)];

% vertical edges
M=numel(object.SettingsStepOffsets)-1;
yedge=nan(M,N+1);
for n=1:(N+1)
    temp=mean(object.Measurement,'Grid1',[left(n) right(n)]);
    deriv=differentiate(temp,object.SettingsDerivativeParams);
    y=deriv.Grid;
    z=deriv.Data.^2;
    z=z/max(z);
    
end

% temp=sum(object.Data,2);
% temp=temp(:);
% y=object.Grid2(:);
% temp=(temp-min(temp))/(max(temp)-min(temp));
% index=(temp>=0.05) & (temp<=0.95);
% p=polyfit(y(index),temp(index),1);
% midpoint=(0.5-p(2))/p(1);
% width=abs(1/p(1));
% positionA=midpoint-width;
% positionB=midpoint+width;
% if temp(1)>temp(end)
%     yboundA=[y(1) positionA];
%     yboundB=[positionB y(end)];
% else
%     yboundB=[y(1) positionA];
%     yboundA=[positionB y(end)]
% end

end