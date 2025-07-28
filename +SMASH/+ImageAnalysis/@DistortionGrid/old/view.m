% view Distortion grid visualization
%
% This method visually displays step wedge information.  The default
% visualization is the measured image.
%     >> view(object);
%     >> view(object,'Measurement');
% Analysis results can also be displayed.
%     >> view(object,'Results');
%
% See also StepWedge, clean, crop, rotate
%

%
% created August 26, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,choice,varargin)


% manage input
if (nargin<2) || isempty(choice)
    choice='measurement';
end
assert(ischar(choice),'ERROR: invalid view choice');

Narg=numel(varargin);
if (Narg>0) && ishandle(varargin{1})
    target=varargin{1};
else
    target=[];
end

% utility functions
    function prepareAxes(label)
        if isempty(target)
            figure;
            target=axes('Box','on',...
                'YDir',object.Measurement.GraphicOptions.YDir);  
            xlabel(object.Measurement.Grid1Label);
            ylabel(object.Measurement.Grid2Label);
            title(label);
        end
    end
    function handleOutput()
        if nargout>0
            varargout{1}=h;
        end
    end
        
% perform requested view
varargout=cell(1,nargout);
switch lower(choice)
    case 'measurement'
        [varargout{:}]=view(object.Measurement,varargin{:});
    case {'points','isopoints'} 
        temp=sprintf('Isopoints for "%s"',...
                object.Measurement.GraphicOptions.Title);
        prepareAxes(temp);
         h=line('Parent',target,...
             'XData',object.IsoPoints(:,1),...
             'YData',object.IsoPoints(:,2),...
             'Color','k','Marker','o');
         handleOutput;
    case 'isomesh'
        temp=sprintf('Isomesh for "%s"',...
            object.Measurement.GraphicOptions.Title);
        prepareAxes(temp);
        x=[];
        y=[];
        for m=1:size(object.IsoMesh1,1)
            x=[x; object.IsoMesh1(m,:)'; NaN]; %#ok<AGROW>
            y=[y; object.IsoMesh2(m,:)'; NaN]; %#ok<AGROW>
        end
        for n=1:size(object.IsoMesh1,2)
            x=[x; object.IsoMesh1(:,n); NaN]; %#ok<AGROW>
            y=[y; object.IsoMesh2(:,n); NaN]; %#ok<AGROW>
        end
        h=line(x,y,'Color','k');      
        handleOutput;
    case 'arcmesh'
        temp=sprintf('Arcmesh for "%s"',...
            object.Measurement.GraphicOptions.Title);
        prepareAxes(temp);
        x=[];
        y=[];
        for m=1:size(object.ArcMesh1,1)
            x=[x; object.ArcMesh1(m,:)'; NaN]; %#ok<AGROW>
            y=[y; object.ArcMesh2(m,:)'; NaN]; %#ok<AGROW>
        end
        for n=1:size(object.ArcMesh1,2)
            x=[x; object.ArcMesh1(:,n); NaN]; %#ok<AGROW>
            y=[y; object.ArcMesh2(:,n); NaN]; %#ok<AGROW>
        end
        h=line(x,y,'Color',object.Measurement.GraphicOptions.LineColor);
        handleOutput;
    case 'vector'
        temp=sprintf('Displacement vectors for "%s"',...
            object.Measurement.GraphicOptions.Title);
        prepareAxes(temp);
        shift1=object.ArcMesh1-object.IsoMesh1;
        shift2=object.ArcMesh2-object.IsoMesh2;
        previous=get(gca,'NextPlot');
        hold on;
        h=quiver(...
            object.IsoMesh1,object.IsoMesh2,shift1,shift2,0,...
            'Color',object.Measurement.GraphicOptions.LineColor,...
            'Marker',object.Measurement.GraphicOptions.Marker);        
        set(gca,'NextPlot',previous);
    case 'results'
        figure;
        subplot(3,1,1);
        view(object,'isomesh',gca);
        subplot(3,1,2);
        view(object,'arcmesh',gca);
        subplot(3,1,3);
        view(object,'vector',gca);
        
    otherwise
        error('ERROR: invalid view choice');
end

end