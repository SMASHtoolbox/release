% CROP Interactive cropping tool for Image objects
%
% Usage:
%   >> object=crop(object,bound1,bound2); % directly input boundaries of 
%                                           crop region
%   >> object=crop(object,'manual'); % interactively select crop region
%   >> object=crop(object,target); % interactively select crop region on a
%                                    specified target already displaying
%                                    the image (useful for some GUI
%                                    applications - target provides
%                                    reference for ROI but changes are made
%                                    to input image object)
%
% See also IMAGE, limit
%

%
% created July 27, 2012 by Daniel Dolan (Sandia National Laboratories)
% modified May 6, 2014 by Tommy Ao (Sandia National Laboratories)
% modified October 6, 2022 by Nathan Brown (Sandia National Laboratories)
%
function object=crop(object,bound1,bound2)

% handle input
if (nargin==1) || strcmpi(bound1,'manual') %|| strcmpi(bound2,'manual')
    h=view(object,'show');
    title(h.axes,'Use zoom/pan to select crop region');    
    hc=uicontrol('Parent',h.panel,...
        'Style','pushbutton','String',' Done ',...
        'Callback','delete(gcbo)');
    waitfor(hc);
    bound1=xlim;
    bound2=ylim;
    close(h.figure);
elseif ishandle(bound1)
    maskPoints = SMASH.ROI.selectROI({'Rectangle', 'xy'}, bound1);
    bound1 = [min(maskPoints.Data(1:2)) max(maskPoints.Data(1:2))];
    bound2 = [min(maskPoints.Data(3:4)) max(maskPoints.Data(3:4))];
elseif nargin < 3
    bound2=[];
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
object.Data=object.Data(:,keep);
keep=(object.Grid2>=bound2(1)) & (object.Grid2<=bound2(2));
object.Grid2=object.Grid2(keep);
object.Data=object.Data(keep,:);

object.LimitIndex1='all';
object.LimitIndex2='all';

object=updateHistory(object);

end