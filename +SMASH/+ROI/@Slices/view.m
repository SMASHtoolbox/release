% view Display points
% 
% This method displays the 'x' or 'y' slices stored in a Slices object.
%    view(object);
% Slices are displayed on the current axes by default.  Alternate locations
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
    case 'x'
        data = [data data.*0];
    case 'y'
        data = [data.*0 data];
    end

    x=data(:,1);
    y=data(:,2);    
end

selection=packtools.call('.ZebraLine',target,'-fixed');
selection.MarkerSize = 0;
selection.LineWidth=2;
selection.Visible='off';

switch object.Mode
    case 'x'
        xdata = [x(:)';x(:)';x(:)'.*inf];
        ydata = [0.*x(:)'+target.YLim(1);0.*x(:)'+target.YLim(2);x(:)'.*inf]; 
    case 'y'
        ydata = [y(:)';y(:)';y(:)'.*inf];
        xdata = [0.*y(:)'+target.XLim(1);0.*y(:)'+target.XLim(2);y(:)'.*inf]; 
end
xdata = xdata(:); ydata = ydata(:);
selection.Data=[xdata ydata];


%set(h,'Visible','on');
selection.Handle(1).Tag=class(object);
selection.Visible='on';

% manage output
if nargout > 0
    varargout{1}=selection;
end

end