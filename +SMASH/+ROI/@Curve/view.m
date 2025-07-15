% view Display curve
%
% This method displays the points and bounding region stored in a Curve
% object.
%    view(object)
% Curves are displayed on the current axes by default.  Alternate locations
% can be specified with an axes handle.
%    view(object,target);
%
% If requested, the ZebraLine objects created by this method are returned
% as an output.
%    h=view(...);
%
% See also Points, define, select
%

%
% created October 3, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,target)

% manage input
if (nargin < 2) || isempty(target)
    target=gca;   
end

% deal with multiple targets
if numel(target) > 1
    for n=1:numel(target)
        assert(ishandle(target(n)) && strcmpi(get(target(n),'Type'),'axes'),...
            'ERROR: invalid target axes');
        view(object,target(n));
    end
    return
end

% manage arrays
N=numel(object);
if N > 1
    for n=1:N        
        temp=view(object(n),target);
        if n == 1
            h=repmat(temp,size(object));
        else
            h=[h temp];
        end
    end
    if nargout > 0
        varargout{1}=h;
    end
    return
end

% plot data points
selection(1)=packtools.call('.ZebraLine',target,'-fixed');
selection(1).Visible='off';
selection(2)=packtools.call('.ZebraLine',target,'-fixed');
selection(2).Visible='off';
selection(2).MarkerSize=0;

table=generateTable(object);
selection(1).Data=table{1};
selection(1).Visible='on';
set(selection(1).Handle,'Tag',class(object));
selection(2).Data=table{2};
selection(2).Visible='on';
set(selection(2).Handle,'Tag',class(object));

% manage output
if nargout > 0
    varargout{1}=selection;
end

end