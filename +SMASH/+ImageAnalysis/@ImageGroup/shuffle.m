% UNDER CONSTRUCTION
% shuffle Shuffle image order
%
%
function out=shuffle(object,index)

% manage input
valid=1:object.NumberImages;

% split and regather
temp=cell(1,object.NumberImages);
[temp{:}]=split(object);
temp=temp(index);
out=SMASH.ImageAnalysis.ImageGroup(temp{:});

end