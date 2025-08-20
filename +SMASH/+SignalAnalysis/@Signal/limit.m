% LIMIT Limit object to a region of interest
%
% This method defines a region of interest in a Signal
% object, limiting the range used in calculations and visualization.
%
% Usage:
%     >> object=limit(object,[lower upper]); % specify bounds in Grid units
%     >> object=limit(object,[lower upper],'fraction'); % specify bounds in fractional units   
%     >> object=limit(object,'all');
%
% Calling this method with the object input only:
%    >> [Grid,Data]=limit(object);
% returns arrays from the limited region.
%
% See also Signal, crop
%

%
% created November 19, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised May 1, 2014 by Daniel Dolan and Randy Spauling
%    -added fractional bound support
function varargout=limit(object,bound,units)

% handle input
if nargin==1    
    if strcmp(object.LimitIndex,'all')
        x=object.Grid;
        y=object.Data;
    else
        x=object.Grid(object.LimitIndex);
        y=object.Data(object.LimitIndex);
    end
    varargout{1}=x;
    varargout{2}=y;
    return
end

if (nargin<3) || isempty(units)
    units='grid';
end

% apply limit bound
if strcmpi(bound,'all')
    object.LimitIndex='all';
elseif strcmp(bound,'manual')
    view(object);
    title(gca,'Use zoom/pan to select limit region');   
    hc=uicontrol('Parent',gcf,...
        'Style','pushbutton','String',' Done ',...
        'Callback','delete(gcbo)');
    waitfor(hc);
    bound=xlim;    
    close(gcf);
    object=limit(object,bound);    
elseif isnumeric(bound) && (numel(bound)==2)  
    bound=sort(bound);
    len=numel(object.Grid);
    switch lower(units)
        case 'grid'
            % do nothing
        case 'fraction'        
            bound(1)=object.Grid(max(1,    floor(max(0,bound(1))*len)));
            bound(2)=object.Grid(min(len+1,floor(min(1,bound(2))*len)));
        otherwise
            error('ERROR: invalid units');
    end
    keep=(object.Grid>=bound(1)) & (object.Grid<bound(2));
    if sum(keep)==0
        warning('Requested limits contain no data points');
    end
    index=1:len;
    object.LimitIndex=index(keep);
else
     error('ERROR: invalid limit bound');
end

if isnumeric(object.LimitIndex)
    match=strcmpi(class(object.LimitIndex),object.Precision);
    if ~match
        object.LimitIndex=feval(object.Precision,object.LimitIndex);
    end            
end

% handle output
varargout{1}=object;

end