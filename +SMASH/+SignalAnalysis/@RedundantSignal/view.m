% view View signals
%
% This method displays signals associated with a redundant measurement.
%    view(object); % show measured signals
%    view(object,'measurement'); % same as above
%    view(object,'source'); % show source signal
%    view(object,'weight'); % show signal weights
%    view(object,'all'); % show all three plots
%
% See also RedundantSignal
%

%
% created March 27, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode)

% manage input
if (nargin < 2) || isempty(mode)
    mode='measurement';
else
    assert(ischar(mode),'ERROR: invalid view mode');
end

% call appropriate view method
switch lower(mode)
    case 'measurement'
        h=view(object.Measurement);
    case 'source'
        if isempty(object.Source)
            figure;
            axes('Box','on');
            title('Incomplete source');
        else
            h=view(object.Source);
            if strcmp(object.Status,'obsolete')
                title('Obsolete source','Color','r');
            end
        end
    case 'weight'
        if isempty(object.Source)
            figure;
            axes('Box','on');
            title('Incomplete weight');
        else
            h=view(object.Weight);
            if strcmp(object.Status,'obsolete')
                title('Obsolete weight','Color','r');
            end
        end        
    case 'all'        
        fig=figure();
        view(object,'measurement');
        ha(1)=gca;
        view(object,'weight');
        ha(2)=gca;
        view(object,'source');
        ha(3)=gca;
        position=[0 0 1 1/3];
        for n=3:-1:1
            new=copyobj(ha(n),fig);
            set(new,'Units','normalized','OuterPosition',position);
            delete(ancestor(ha(n),'figure'));
            position(2)=position(2)+1/3;
        end
        ha=findobj(fig,'Type','axes');
        linkaxes(ha,'x');
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout > 0
    varargout{1}=h;
end

end