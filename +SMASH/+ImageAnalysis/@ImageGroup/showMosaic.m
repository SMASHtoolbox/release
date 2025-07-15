% SHOWMOSAIC Standard view showing ImageGroup object as a mosaic of images
%
% See also ImageGroup, view, showSingle

% created January 28, 2016 by Sean Grant (Sandia National Laboratories/UT)
%
function varargout=showMosaic(object,target)

% Handle inputs
if (nargin<2) || isempty(target)
    h=basic_figure;
    h.axes=axes('Parent',h.panel,'Box','on');
else
    h.figure=ancestor(target,'figure');
    h.axes=target;
    cla(h.axes);
end

temp=cell(object.NumberImages,1);
[temp{:}]=split(object);


NImages=object.NumberImages;
size1=round(sqrt(NImages)+.4999);
size2=ceil(NImages./size1);
for n=1:NImages
    subplot(size1,size2,n)
    view(temp{n},[],gca);
end


% handle output
if nargout>=1
    varargout{1}=h;
end
    
    
end