% SPLIT Divide ImageGroup into Image objects
%
% This method breaks up an ImageGroup object into a collection of Image
% objects.
%    >> [object1,object2,...]=split(object)
%
% A call for specific Image numbers can also be made:
%   >> [object1,object2,...]=split(object,[imageNumbers])
%
% See also ImageGroup, gather
%

%
% created January 7, 2016 by Sean Grant (Sandia National Laboratories/UT)
%

function varargout=split(object,imageNumbers)

% handle selective image call
if nargin>1
    assert(nargout<=(numel(imageNumbers)),...
    'ERROR: too many outputs requested');
    
    temp=cell(object.NumberImages,1);
    [temp{:}]=split(object);
    varargout=cell(1,numel(imageNumbers));
    for n=1:(numel(imageNumbers))
        assert(rem(imageNumbers(n),1)==0,'Image selections must be an integer');
        varargout{n}=temp{imageNumbers(n)};
    end
    return
end
    
    
assert(nargout<=object.NumberImages,...
    'ERROR: too many outputs requested');
varargout=cell(1,object.NumberImages);

[bound1,bound2]=limit(object);
bound1=[min(bound1) max(bound1)];
bound2=[min(bound2) max(bound2)];
for n=1:object.NumberImages
    varargout{n}=SMASH.ImageAnalysis.Image(object.Grid1,object.Grid2,object.Data(:,:,n));
    varargout{n}=limit(varargout{n},bound1,bound2);
    varargout{n}.Source='ImageGroup split';    
    varargout{n}.Name=object.Legend{n};
    varargout{n}.DataLim=object.DataLim;
    varargout{n}.DataScale=object.DataScale;
    varargout{n}.LimitIndex1=object.LimitIndex1;
    varargout{n}.LimitIndex2=object.LimitIndex2;
    varargout{n}.Grid1Label=object.Grid1Label;
    varargout{n}.Grid2Label=object.Grid2Label;
    varargout{n}.DataLabel=object.DataLabel;
    varargout{n}.GraphicOptions=object.GraphicOptions;
    varargout{n}.GraphicOptions.Title=object.Legend{n};
    varargout{n}.Precision=object.Precision;
end

end