% LIMIT Limit SignalGroup to a region of interest
%
% This method defines a region of interest in a SignalGroup
% object, limiting the range used in calculations and visualization.
%     >> object=limit(object,[lower upper]); % specify Grid range
% Information outside the limited region is *not* destroyed and can be
% accessed by moving or resetting the region.
%     >> object=limit(object,'all'); % reset limited region
%
% Calling this method with the object input only:
%    >> [Grid,Data]=limit(object);
% returns arrays from the limited region.
%
% See also Signal, crop
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=limit(object,bound)

% handle input
if nargin==1    
    if strcmp(object.LimitIndex,'all')
        x=object.Grid;
        y=object.Data;
    else
        x=object.Grid(object.LimitIndex);
        y=object.Data(object.LimitIndex,:);
    end
    varargout{1}=x;
    varargout{2}=y;
    return
end

% apply limit bound
if strcmpi(bound,'all')
    object.LimitIndex='all';
elseif isnumeric(bound) && (numel(bound)==2)    
    keep=(object.Grid>=bound(1)) & (object.Grid<bound(2));
    index=1:numel(object.Grid);
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