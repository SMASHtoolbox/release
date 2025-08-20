% SLICE  Generate Image slices (lineouts)
%
% This function slices an Image object at specified grid locations.
%    >> result=slice(object,coordinate,value);
% The input "coordinate"  should be 'Grid1' or 'Grid2'; "value" can be one
% or more grid locations within that grid.  If these inputs are omitted,
% the user will be prompted to select them.  The output of this method is a
% SignalGroup object; slices are plotted in a new figure when no output is
% specified.
%
% See also Image, mean, SignalAnalysis.SignalGroup
%

%
% created November 25, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified by M. Schaeuble (SNL) on March 2, 2021
function varargout=slice(object,coordinate,value,width)

% handle input
if (nargin<2) || isempty(coordinate)
    coordinate=questdlg('Choose slice coordinate','Slice coordinate',...
        ' Grid1 ',' Grid2 ',' cancel ',' Grid1 ');
    coordinate=strtrim(coordinate);
    if strcmp(coordinate,'cancel')
        return
    end
elseif ~strcmpi(coordinate,'Grid2') && ~strcmpi(coordinate,'Grid1')
    error('ERROR: %s is an invalid coordinate',coordinate);
end

if nargin < 3
    value=[];
end

if (nargin < 4) || isempty(width)
    width=0;
end

if isempty(value)
    value=SelectValue(coordinate,object,width);       
end

% calculate slices for width=0 case
if (width == 0.0)
    label=cell(1,numel(value));
    [x,y,z]=limit(object);
    switch lower(coordinate)
        case 'grid1'
            Grid=y;
            Data=nan(numel(y),numel(value));
            for k=1:numel(value)
                Data(:,k)=interp2(object.Grid1,object.Grid2,object.Data,...
                    value(k),Grid);
                label{k}=sprintf('%s=%g',coordinate,value(k));
            end               
            result=SMASH.SignalAnalysis.SignalGroup(y,Data);
            result.GridLabel=object.Grid2Label;
        case 'grid2'
            Grid=x;
            Data=zeros(numel(value),numel(x));
            for k=1:numel(value)
                Data(k,:)=interp2(object.Grid1,object.Grid2,object.Data,...
                    Grid,value(k));
                label{k}=sprintf('%s=%g',coordinate,value(k));
            end
            result=SMASH.SignalAnalysis.SignalGroup(x,transpose(Data));
            result.GridLabel=object.Grid1Label;
    end
%and for the case with a specified width
else
    label=cell(1,numel(value));
    [x,y,z]=limit(object);
    switch lower(coordinate)
        case 'grid1'
            Grid=y;
            Data=nan(numel(y),numel(value));
            for k=1:numel(value)
                tmpImg = crop(object,[value(k)-width value(k)+width],[]);
                dataTmp = mean(tmpImg,'Grid1');
                Data(:,k) = dataTmp.Data;
                label{k} = sprintf('%s=%g',coordinate,value(k));
            end               
            result=SMASH.SignalAnalysis.SignalGroup(y,Data);
            result.GridLabel=object.Grid2Label;
        case 'grid2'
            Grid=x;
            Data=zeros(numel(value),numel(x));
            for k=1:numel(value)
                tmpImg = crop(object,[],[value(k)-width value(k)+width]);
                dataTmp = mean(tmpImg,'Grid2');
                Data(k,:) = dataTmp.Data;
                label{k} = sprintf('%s=%g',coordinate,value(k));
            end
            result=SMASH.SignalAnalysis.SignalGroup(x,transpose(Data));
            result.GridLabel=object.Grid1Label;
    end
end
result.DataLabel=object.DataLabel;
result.GraphicOptions.Title=sprintf('%s slice of "%s"',coordinate,object.Name);
result.Legend=label;

% handle output
if nargout==0
    view(result);
end

if nargout==1
    varargout{1}=result;
end

if nargout==2 % this mode is undocumented
    varargout{1}=coordinate;
    varargout{2}=z;
end

end

%% 
function value=SelectValue(coordinate,object,width)

% create selection interface
h=view(object,'show');
title(h.axes,'Choose slice: ');
switch lower(coordinate)
    case 'grid1'
        Grid2=ylim(h.axes);
        Grid1=nan(size(Grid2));
    case 'grid2'
        Grid1=xlim(h.axes);
        Grid2=nan(size(Grid1));         
end
hline=line('Parent',h.axes,'XData',Grid1,'YData',Grid2,...
    'Color','m',...
    'Tag','SliceGuide');
hlineUp = line('Parent',h.axes,'XData',Grid1,'YData',Grid2,...
    'Color','m','LineStyle','--',...
    'Tag','SliceGuide');
hlineDown = line('Parent',h.axes,'XData',Grid1,'YData',Grid2,...
    'Color','m','LineStyle','--',...
    'Tag','SliceGuide');

fig=ancestor(h.axes,'figure');
set(fig,'WindowButtonMotionFcn',@MoveSliceGuide);
set(h.image,'ButtonDownFcn',@ButtonDown);
set(hline,'ButtonDownFcn',@ButtonDown);
set(hlineUp,'ButtonDownFcn',@ButtonDown);
set(hlineDown,'ButtonDownFcn',@ButtonDown);
    function MoveSliceGuide(varargin)
        pos=get(h.axes,'CurrentPoint');
        Grid1=repmat(min(max(pos(1,1),min(xlim(h.axes))),max(xlim(h.axes))),[1 2]);
        Grid2=repmat(min(max(pos(1,2),min(ylim(h.axes))),max(ylim(h.axes))),[1 2]);
        switch lower(coordinate)
            case 'grid1'
                Grid2=ylim(h.axes);
                Grid1Up=Grid1+width;
                Grid1Down=Grid1-width;
                temp=sprintf('Choose slice: %s = %g',object.Grid1Label,Grid1(1));
            case 'grid2'               
                Grid1=xlim(h.axes);
                Grid2Up=Grid2+width;
                Grid2Down=Grid2-width;
                temp=sprintf('Choose slice: %s = %g',object.Grid2Label,Grid2(1));
        end
        
        %added by MS to allow for a width
        switch lower(coordinate)
            case 'grid1'
                set(hline,'Xdata',Grid1,'YData',Grid2);
                set(hlineUp,'Xdata',Grid1Up,'YData',Grid2);
                set(hlineDown,'Xdata',Grid1Down,'YData',Grid2);
            case 'grid2'               
                set(hline,'Xdata',Grid1,'YData',Grid2);
                set(hlineUp,'Xdata',Grid1,'YData',Grid2Up);
                set(hlineDown,'Xdata',Grid1,'YData',Grid2Down);
        end
        %set(hline,'Xdata',Grid1,'YData',Grid2);
        %set(hlineUp,'Xdata',Grid1,'YData',Grid2);
        title(h.axes,temp);
    end

    function ButtonDown(varargin)        
        set(hline,'Tag','SliceLine');
        set(hlineUp,'Tag','SliceLine');
    end
        
% wait for user to click on image (which changes the slice guide tag)
waitfor(hline,'Tag');
switch lower(coordinate)
    case 'grid1'
        value=get(hline,'XData');
    case 'grid2'
        value=get(hline,'YData');
end
value=value(1);

delete(fig);

end