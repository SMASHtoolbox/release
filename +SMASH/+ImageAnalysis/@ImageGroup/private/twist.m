
function object=twist(object,theta)

% split up ImageGroup
temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    tempObj{n}=twistSingle(temp{n},theta);
end

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});


end

