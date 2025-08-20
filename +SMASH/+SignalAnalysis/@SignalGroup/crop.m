% CROP Crop Grid range
%
% This method crops SignalGroup objects, disposing all information outside
% of the specified Grid bound.
%    >> new=crop(object,bound);
% The "bound" input must be an array specifing the minimum and maximum Grid
% values of the crop region.  All grid points inside this region are passed
% to new object.
% 
% See also SignalGroup, limit
%

%
% created November 21, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=crop(object,bound)

% handle input
if nargin==1 || strcmpi(bound,'manual') || isempty(bound)
    h=view(object);
    haxes=ancestor(h(1),'axes');
    title(haxes,'Use zoom/pan to select crop region');    
    fig=ancestor(haxes,'figure');
    hc=uicontrol('Parent',fig,...
        'Style','pushbutton','String',' Done ',...
        'Callback','delete(gcbo)');
    waitfor(hc);
    bound=xlim;    
    close(fig);
else
    assert(isnumeric(bound) && (numel(bound)==2),...
    'ERROR: two bound values are needed');
end

bound=sort(bound);

% crop the object
keep=(object.Grid>=bound(1)) & (object.Grid<=bound(2));
object.Grid=object.Grid(keep);
object.Data=object.Data(keep,:);

object=updateHistory(object);

end