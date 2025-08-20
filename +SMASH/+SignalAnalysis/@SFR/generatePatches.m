%%
function hc=generatePatches(object,result,cutoff)

data=result.Data;

if ~isnan(cutoff)
    keep=data(:,4) >= cutoff;
    data=data(keep,:);    
end
if size(data,2) > 4
    keep=logical(data(:,end));
    data=data(keep,1:end-1);
end
data=transpose(data);

box on;
hold on;
dx=result.Parameter.RiseTime/2;
columns=size(data,2);
[x,y,z]=deal(nan(4,columns));
x(1,:)=data(1,:)-dx;
x(2,:)=data(1,:)+dx;
x(3,:)=data(1,:)+dx;
x(4,:)=data(1,:)-dx;

dy=result.Parameter.PeakWidth;
%dy=data(3,:);
y(1,:)=data(2,:)-dy;
y(2,:)=data(2,:)-dy;
y(3,:)=data(2,:)+dy;
y(4,:)=data(2,:)+dy;
color=data(4,:);
for k=1:4
    z(k,:)=color;
end
patch(x,y,z,color,'LineStyle','none');

colormap(object.Colormap);
xlabel('Time');
ylabel('Frequency');
Cmin=floor(min(color));
Cmax=ceil(max(color));
while Cmax-Cmin < 3
    Cmax=Cmax+1;
    Cmin=Cmin-1;
end
caxis([Cmin Cmax]);
hc=colorbar();
ylabel(hc,'SNR (dB)');

end