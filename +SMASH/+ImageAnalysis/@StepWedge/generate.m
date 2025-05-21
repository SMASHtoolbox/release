% generate Generate exposure table
%

%
% created February 5, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=generate(object)

% generate exposure table
N=numel(object.Settings.StepOffsets);
OD=sort(object.Settings.StepLevels);
OD=OD(end:-1:1);

OD=repmat(OD,[N 1]);
offset=sort(object.Settings.StepOffsets);
offset=offset(end:-1:1);
layer=zeros(size(OD));
for n=1:numel(offset)
    OD(n,:)=OD(n,:)+offset(n);
    layer(n,:)=n;
end

exposure=10.^(-OD);
exposure=exposure/median(exposure(:)); % normalize by median
exposure=exposure(:);
Nexposure=numel(exposure);

% calculate levels and associate with exposure
level=zeros(Nexposure,1);
for k=1:size(object.Results.RegionTable,1)
    x1=object.Results.RegionTable(k,1);
    x2=x1+object.Results.RegionTable(k,3);
    y1=object.Results.RegionTable(k,2);
    y2=y1+object.Results.RegionTable(k,4);
    n=(object.Measurement.Grid1>=x1) & (object.Measurement.Grid1<=x2);
    m=(object.Measurement.Grid2>=y1) & (object.Measurement.Grid2<=y2);
    temp=object.Measurement.Data(m,n);
    level(k)=median(temp(:));    
end
[level,index]=sort(level);
%exposure=exposure(index);
layer=layer(index);

% create transfer curve
%x=log10(exposure);
x=-OD(index);
x=x-median(x);
y=level;
object.Results.TransferPoints=[x(:) y(:) layer(:)];

end