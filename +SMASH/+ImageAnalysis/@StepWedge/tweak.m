% tweak Automatically adjust step offsets
%
% This method automatically adjusts offset values on a step wedge for
% best overlap in the transfer curve.
%    object=tweak(object);
%
% See also StepWedge, analyze, clean, crop
%

%
% created February 5, 2016 by Daniel Dolan (Sandia National Laboatories)

%
function object=tweak(object)

% initial preparations
if ~object.Cropped
    object=crop(object,'manual');
end

object=rotate(object,'auto');
object=locate(object);
object=generate(object);

% adjust offsets based on overlap region 
table=sortrows(object.Results.TransferPoints,1);
k=(table(:,3)==1);
x1=table(k,1);
y1=table(k,2);
layer=unique(table(:,3));
correction=zeros(size(object.Settings.StepOffsets));
for m=2:numel(layer)
    k=(table(:,3)==layer(m));
    x=table(k,1);
    y=table(k,2);
    ymin=max(min(y),min(y1));
    ymax=min(max(y),max(y1));
    k=(y1>=ymin) & (y1<=ymax);
    param=polyfit(y1(k),x1(k),1);    
    k= (y>=ymin)  & (y<=ymax);
    fit=polyval(param,y(k));
    correction(m)=mean(fit-x(k));    
end

% apply changes
object.Settings.StepOffsets=object.Settings.StepOffsets+correction;
object=generate(object);

end