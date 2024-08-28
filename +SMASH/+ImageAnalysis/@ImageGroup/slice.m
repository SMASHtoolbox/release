% SLICE  Generate slices (lineouts) of ImageGroup objects
%
% This function slices an Image object at a specified grid location.
%    >> result=slice(object,coordinate,value);
% The input "coordinate"  should be 'Grid1' or 'Grid2'; "value" can only be
% one location within that grid (at the moment).  If these inputs are omitted,
% the user will be prompted to select them.  The output of this method is a
% SignalGroup object; slices are plotted in a new figure when no output is
% specified.
%
% See also ImageGroup, SMASH.SignalAnalysis.SignalGroup
%

%
% created November 25, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)
%   - modified from Image method
function varargout=slice(object,coordinate,value)

NImages=object.NumberImages;

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

if (nargin<3) || isempty(value) % prompt user to select slices
    
    % prompt for Image to visualize during selection
    fig=SMASH.MUI.Dialog;
    fig.Name='Image Selection';
    fig.Hidden=true; % temporarily hide dialog for speed
    
    choices=num2cell(1:NImages);
    addblock(fig,'popup','Select Image Number:',choices); % popup menu block

    h=addblock(fig,'button',' OK '); % button block
    set(h,'Callback',@pullValue); % button probes dialog state and closes it

    fig.Hidden=false; % reveal finished dialog
    waitfor(h);
    
    % call selection on designated Image
    temp=cell(NImages,1);
    [temp{:}]=split(object);
    value=SelectValue(coordinate,temp{str2double(frame)});     
else
    assert(numel(value)==1,'Error: Only one value is currently supported');
end   

% calculate slices
label=cell(1,NImages);
[x,y,z]=limit(object);
switch lower(coordinate)
    case 'grid1'
        Grid=y;
        Data=nan(numel(y),NImages);
        for k=1:NImages
            Data(:,k)=interp2(object.Grid1,object.Grid2,object.Data(:,:,k),...
                value,Grid);
            label{k}=sprintf('%s',object.Legend{k});
        end               
        result=SMASH.SignalAnalysis.SignalGroup(y,Data);
        result.GridLabel=object.Grid2Label;
    case 'grid2'
        Grid=x;
        Data=zeros(NImages,numel(x));
        for k=1:NImages
            Data(k,:)=interp2(object.Grid1,object.Grid2,object.Data(:,:,k),...
                Grid,value);
            label{k}=sprintf('%s',object.Legend{k});
        end
        result=SMASH.SignalAnalysis.SignalGroup(x,transpose(Data));
        result.GridLabel=object.Grid1Label;
end
result.DataLabel=object.DataLabel;
result.GraphicOptions.Title=sprintf('%s=%g slice of "%s"',coordinate,value,object.Name);
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

%% Callbacks

function pullValue(src,varargin)
    frame=probe(fig);delete(fig);
end

end

%% 
function value=SelectValue(coordinate,object)

% create selection interface
h=view(object,'show'); % should make this 'snapshot' if that gets made.
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

fig=ancestor(h.axes,'figure');
set(fig,'WindowButtonMotionFcn',@MoveSliceGuide);
set(h.image,'ButtonDownFcn',@ButtonDown);
set(hline,'ButtonDownFcn',@ButtonDown);
    function MoveSliceGuide(varargin)
        pos=get(h.axes,'CurrentPoint');
        Grid1=repmat(min(max(pos(1,1),min(xlim(h.axes))),max(xlim(h.axes))),[1 2]);
        Grid2=repmat(min(max(pos(1,2),min(ylim(h.axes))),max(ylim(h.axes))),[1 2]);
        switch lower(coordinate)
            case 'grid1'
                Grid2=ylim(h.axes);
                temp=sprintf('Choose slice: %s = %g',object.Grid1Label,Grid1(1));
            case 'grid2'               
                Grid1=xlim(h.axes);
                temp=sprintf('Choose slice: %s = %g',object.Grid2Label,Grid2(1));
        end        
        set(hline,'Xdata',Grid1,'YData',Grid2);
        title(h.axes,temp);
    end

    function ButtonDown(varargin)        
        set(hline,'Tag','SliceLine');            
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


