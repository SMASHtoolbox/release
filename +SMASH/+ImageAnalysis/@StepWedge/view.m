% view Step wedge visualization
%
% This method visually displays step wedge information.  The default
% visualization is the measured image.
%    view(object);
%    view(object,'measurement');
% Analysis results can also be displayed.
%    view(object,'results');
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

% perform requested view
varargout=cell(1,nargout);
switch lower(choice)
    case 'measurement'
        [varargout{:}]=view(object.Measurement,varargin{:});
    case 'results'
        assert(object.Analyzed,'ERROR: object has not been analyzed yet');
        SMASH.MUI.Figure;
        % step regions
        ha(1)=subplot(3,1,1);
        view(object,'Measurement','show',gca);
        temp=sprintf('Wedge regions for ''%s''',object.Measurement.GraphicOptions.Title);
        title(ha(1),temp);
        for n=1:size(object.Results.RegionTable,1)
            rectangle('Position',object.Results.RegionTable(n,:),'EdgeColor','k','LineStyle','-');
            rectangle('Position',object.Results.RegionTable(n,:),'EdgeColor','w','LineStyle','--');
        end        
        % forward transfer
        ha(2)=subplot(3,1,2);
        box on;
        table=object.Results.TransferPoints;
        x=10.^table(:,1);
        y=table(:,2);
        layer=table(:,3);
        N=max(layer);
        color=lines(N);
        for k=1:N
            keep=(layer==k);           
            line(x(keep),y(keep),...
                'LineStyle','none','Color',color(k,:),'Marker','o');
        end
        line(object.Results.ForwardTable(:,1),object.Results.ForwardTable(:,2),...
            'Color','k');
        xlabel('Relative exposure');        
        ylabel('Density');
        set(gca,'XScale','log');
        %min_y=min(y);
        %max_y=max(y);
        %Ly=max_y-min_y;
        %y1=min_y+object.Settings.AnalysisRange(1)*Ly;
        %y2=min_y+object.Settings.AnalysisRange(2)*Ly;
        %line(xlim,repmat(y1,[1 2]),'Color','k','LineStyle','--');
        %line(xlim,repmat(y2,[1 2]),'Color','k','LineStyle','--');
        % reverse transfer
        ha(3)=subplot(3,1,3); %#ok<NASGU>
        plot(object.Results.ReverseTable(:,1),object.Results.ReverseTable(:,2),'k');
        xlabel('Density');
        ylabel('Relative exposure');
        set(gca,'YScale','log');
        %line(repmat(y1,[1 2]),ylim,'Color','k','LineStyle','--');
        %line(repmat(y2,[1 2]),ylim,'Color','k','LineStyle','--');
    otherwise
        error('ERROR: invalid view choice');
end

end