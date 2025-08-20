% LIMIT Limit object to a region of interest
%
% This method defines a region of interest in a ImageGroup
% object, limiting the range used in calculations and visualization.
%
% Any limiting applies to all images in the ImageGroup object.
% 
% Usage:
%     >> object=limit(object,array1,array2);
% Three limit choices are available.  The choice 'all' provides no
% limit on the object range.
%    >> object=limit(object,'all');
% Passing an array of logical values allows portions of the image to be
% made active (true) or passive (false);
%    >> object=limit(object,object.Grid1>0); % positive grid1 points only
% Active points may also be defined through a bound array, which has the
% form [lower upper].
%    >> object=limit(object,'all',[0 +inf]); % positive grid2 points
% Bound arrays can be specified in grid units (as shown above) or as
% fractions of the total grid span.
%    >> object=limit(object,[0.4 0.6],[0.4 0.5],'fraction'); % central 20%
% To interactively select (manual) limit region
%    >> object=limit(object,'manual');
% Calling this method with no inputs returns arrays from the limited
% region.
%    >> [Grid1,Grid2,Data]=limit(object);
%
% See also Image, crop
%

%
% created November 19, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised May 1, 2014 by Daniel Dolan
%    -added fractional bound support
% revised May 5, 2014 by Tommy Ao
%    -added interactively select (manual) limit region
% revised October 1, 2014 by Daniel Dolan
%    -changed boundary handling to include upper and lower limit (>= and <=)
function varargout=limit(object,bound1,bound2,units)

% handle input
if nargin==1
    if strcmp(object.LimitIndex1,'all')
        x=object.Grid1;
        kx=1:numel(x);
    else
        kx=object.LimitIndex1;
        x=object.Grid1(kx);
    end
    if strcmp(object.LimitIndex2,'all')
        y=object.Grid2;
        ky=1:numel(y);
    else
        ky=object.LimitIndex2;
        y=object.Grid2(ky);
    end
    z=object.Data(ky,kx,:);
    varargout{1}=x;
    varargout{2}=y;
    varargout{3}=z;
    return
end

if nargin<3
    bound2=[];
end

if (nargin<4) || isempty(units)
    units='grid';
end

% interactively select (manual) limit region
if strcmpi(bound1,'manual') || strcmpi(bound2,'manual')
    imageNumber=1;
    if isnumeric(bound1) && ~isempty(bound1)
        imageNumber=bound1;
    elseif isnumeric(bound2) && ~isempty(bound2)
        imageNumber=bound2;
    end
    h=view(object,imageNumber);
    title(h.axes,'Use zoom/pan to select limit region');    
    hc=uicontrol('Parent',h.panel,...
        'Style','pushbutton','String',' Done ',...
        'Callback','delete(gcbo)');
    waitfor(hc);
    bound1=xlim;
    bound2=ylim;
    close(h.figure);
    if isempty(bound1) || strcmpi(bound1,'all')
        bound1=[min(object.Grid1) max(object.Grid1)];
    end
    if isempty(bound2) || strcmpi(bound2,'all')
        bound2=[min(object.Grid2) max(object.Grid2)];
    end
end

% apply first limit array
if isempty(bound1)
    % do nothing with Grid1
elseif strcmpi(bound1,'all')
    object.LimitIndex1='all';
elseif isnumeric(bound1) && (numel(bound1)==2)
    len=numel(object.Grid1);
    switch lower(units)
        case 'grid'
            % do nothing
        case 'fraction'
            bound1(1)=object.Grid1(max(1,    floor(max(0,bound1(1))*len)));
            bound1(2)=object.Grid1(min(len+1,floor(min(1,bound1(2))*len)));
        otherwise
            error('ERROR: invalid units');
    end
    keep=(object.Grid1>=bound1(1)) & (object.Grid1<=bound1(2));
    assert(sum(keep)>0,'ERROR: no Grid1 points in limited region');
    index=1:len;
    object.LimitIndex1=index(keep);
else
    error('ERROR: invalid limit array');
end

if isnumeric(object.LimitIndex1)
    match=strcmpi(class(object.LimitIndex1),object.Precision);
    if ~match
        object.LimitIndex1=feval(object.Precision,object.LimitIndex1);
    end
end

% apply second limit array
if isempty(bound2)
    % do nothing with Grid2
elseif strcmpi(bound2,'all')
    object.LimitIndex2='all';
elseif islogical(bound2)
    index=1:numel(object.Grid2);
    if numel(index)~=numel(bound2)
        error('ERROR: invalid logical array');
    end
    object.LimitIndex2=index(bound2);
elseif isnumeric(bound2) && (numel(bound2)==2)
    len=numel(object.Grid2);
    switch lower(units)
        case 'grid'
            % do nothing
        case 'fraction'
            bound2(1)=object.Grid2(max(1,    floor(max(0,bound2(1))*len)));
            bound2(2)=object.Grid2(min(len+1,floor(min(1,bound2(2))*len)));
        otherwise
            error('ERROR: invalid units');
    end    
    keep=(object.Grid2>=bound2(1)) & (object.Grid2<=bound2(2));
    assert(sum(keep)>0,'ERROR: no Grid2 points in limited region');
    index=1:len;
    object.LimitIndex2=index(keep);
else
    error('ERROR: invalid limit array');
end

if isnumeric(object.LimitIndex2)
    match=strcmpi(class(object.LimitIndex2),object.Precision);
    if ~match
        object.LimitIndex2=feval(object.Precision,object.LimitIndex2);
    end
end

% handle output
varargout{1}=object;

end