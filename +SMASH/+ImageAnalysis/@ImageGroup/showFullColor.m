% SHOW Standard view showing Image objects
%
% See also Image, detail, explore, slice, view

% created October 15, 2013 by Tommy Ao (Sandia National Laboratories)
%
function varargout=showFullColor(object,target)

assert(object.NumberImages==3,'Error: This mode requires exactly 3 image layers');

% handle input
if (nargin<2) || isempty(target)
    h=basic_figure;
    h.axes=axes('Parent',h.panel,'Box','on');
else
    h.figure=ancestor(target,'figure');
    h.axes=target;
    cla(h.axes);
end

% display image
[x,y,z]=limit(object);
switch object.DataScale
    case 'log'
        z=log10(z);
        object.DataLabel=sprintf('%s (log scale)',object.DataLabel);
    case 'dB'
        z=10*log10(z);
        object.DataLabel=sprintf('%s (dB)',object.DataLabel);
end

h.image=imagesc(uint8(object.Data));
apply(object.GraphicOptions,h.axes);
axis(h.axes,'tight');

colormap(h.axes,object.GraphicOptions.ColorMap);
xlabel(h.axes,object.Grid1Label);
ylabel(h.axes,object.Grid2Label);
title(h.axes,object.GraphicOptions.Title);


if ~isempty(object.DataLim)
    caxis(h.axes,object.DataLim);
end

figure(h.figure);

% handle output
if nargout>=1
    varargout{1}=h;
end
    
    
end