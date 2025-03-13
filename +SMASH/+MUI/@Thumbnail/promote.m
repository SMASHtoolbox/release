% promote Promote axes to the primary
%
% This method promotes a specified axes to the be primary axes.
%    promote(object,haxes);
% NOTE: there must be at least two axes in the parent object (figure,
% uipanel, or uitab) for this operation to work.
% 
% See also Thumbnail, refresh
%

%
% created August 16, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function promote(object,selection)

if numel(object.Axes) < 2
    error('ERROR: not enough axes objects present');
end

% manage input
if (nargin < 2) || isempty(selection)
    selection=object.Axes(2);
end
index=find(selection==object.Axes,1);
assert(~isempty(index),'ERROR: axes selection not found');

temp=object.Axes;
temp(index)=temp(1);
temp(1)=selection;
temp=flipud(temp);

%go through an rearrange if there are legends
neworder=zeros(1,numel(object.Parent.Children));
for k=1:numel(object.Parent.Children)
    location=find(object.Parent.Children(k)==temp,1);
    if ~isempty(location)
        neworder(k)=location;
    end
    if k > 1
        if neworder(k-1) == 0
            neworder(k-1)=neworder(k)-0.5;
        end
    end
end

%turn off legends for subplots 
tempChild=object.Parent.Children;
for k=1:numel(tempChild)
    newplace=sum(neworder <= neworder(k));
    tempChild(newplace)=object.Parent.Children(k);
    %hide legends for smaller thumbnails
    if strcmp(object.Parent.Children(k).Tag,'legend')
        if newplace < numel(tempChild)-1
            tempChild(newplace).Visible='off';
        else
            tempChild(newplace).Visible='on';
        end
    end
end

set(object.Parent,'Children',tempChild);

refresh(object);

fig=ancestor(object.Parent,'figure');
set(fig,'CurrentAxes',object.Axes(1));

end