% CROP Interactive cropping tool for ImageGroup objects
%
% Usage:
%   >> object=crop(object,bound1,bound2); % directly input boundaries of 
%                                           crop region
%   >> object=crop(object,[imageNumber],'manual'); % interactively select crop region
% You may select which image you want to interact with, though the cropping
% is still performed on all images.
%
% See also IMAGEGROUP, limit
%

%
% created July 27, 2012 by Daniel Dolan (Sandia National Laboratories)
% modified May 6, 2014 by Tommy Ao (Sandia National Laboratories)
% modified February 11, 2016 by Sean Grant (Sandia National Laboratories)
% 
function object=crop(object,frame,bound1,bound2)

% handle input
if strcmpi(frame,'manual')
    frame=1;
    bound1='manual';
elseif length(frame)==2 || isempty(frame)
    bound2=bound1;
    bound1=frame;
    frame=1;
end
assert(rem(frame,1)==0,'Frame slection must be an integer')

if strcmpi(bound1,'manual') || strcmpi(bound2,'manual')
    h=view(object,frame);
    title(h.axes,'Use zoom/pan to select crop region');    
    hc=uicontrol('Parent',h.panel,...
        'Style','pushbutton','String',' Done ',...
        'Callback','delete(gcbo)');
    waitfor(hc);
    bound1=xlim;
    bound2=ylim;
    close(h.figure);
end

if isempty(bound1) || strcmpi(bound1,'all')
    bound1=[min(object.Grid1) max(object.Grid1)];
end
if isempty(bound2) || strcmpi(bound2,'all')
    bound2=[min(object.Grid2) max(object.Grid2)];
end

% crop object
keep=(object.Grid1>=bound1(1)) & (object.Grid1<=bound1(2));
object.Grid1=object.Grid1(keep);
object.Data=object.Data(:,keep,:);
keep=(object.Grid2>=bound2(1)) & (object.Grid2<=bound2(2));
object.Grid2=object.Grid2(keep);
object.Data=object.Data(keep,:,:);

object.LimitIndex1='all';
object.LimitIndex2='all';

object=updateHistory(object);

end