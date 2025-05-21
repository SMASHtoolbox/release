% view Display points
% 
% This method displays the (x,y) locations stored in a Points object.
%    view(object);
% Points are displayed on the current axes by default.  Alternate locations
% can be specified with an axes handle.
%    view(object,target);
%
%
% See also Points, define, select
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,target)

% manage input
if (nargin < 2) || isempty(target)
    target=gca;   
else
    assert(ishandle(target) && strcmpi(get(target,'Type'),'axes'),...
        'ERROR: invalid target axes');   
end

% manage arrays
N=numel(object);
if N > 1
    for n=1:N        
        temp=view(object(n),target);
        if n == 1
            h=repmat(temp,size(object));
        else
            h(n)=temp;
        end
    end
    if nargout > 0
        varargout{1}=h;
    end
    return
end

% plot data points
if isempty(object.Data)
    x=[];
    y=[];
else
    data=report(object);
    switch object.Mode
        case {'closed' 'convex'}
            data(end+1,:)=data(1,:);
    end
    x=data(:,1);
    y=data(:,2);    
end

selection=packtools.call('.ZebraLine',target,'-fixed');

switch object.Mode
    case 'open'
        selection.LineWidth=0;
    otherwise
        selection.LineWidth=2;
end
selection.MarkerSize=10;

selection.Visible='off';

selection.Data=[x(:) y(:)];

switch object.Mode
    case 'open'
        selection.LineWidth=0;
    otherwise
        selection.LineWidth=2;
end

%set(h,'Visible','on');
selection.Handle(1).Tag=class(object);
selection.Visible='on';

% manage output
if nargout > 0
    varargout{1}=selection;
end

end