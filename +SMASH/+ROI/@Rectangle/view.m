% view Display rectangle
% 
% This method displays the (x,y) locations stored in a Rectangle object.
%    view(object);
% By default, these points are displayed on the current axes.  Alternate
% locations can be specified with an axes handle.
%    view(object,target);
% If requested, the line object created by this method is returned as an
% output.
%    h=view(...);
%
% See also Points, define, select
%

%
% created September 25, 2017 by Daniel Dolan (Sandia National Laboratories)
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
selection=packtools.call('.ZebraLine',target,'-fixed');
selection.Visible='off';
selection.MarkerSize=0;

selection.Data=generateTable(report(object),get(target,'Children'));
selection.Handle(1).Tag=class(object);
selection.Visible='on';
%setappdata(selection,'MaxBound',[xm ym]);

% manage output
if nargout > 0
    varargout{1}=selection;
end

end