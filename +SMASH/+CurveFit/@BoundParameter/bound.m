% bound Define parameter bounds
%
% This method defines the bounds associated with a set of parameters.
% Bounds may be specified for a specific parameter (by index):
%    object=bound(object,index,[min max]); 
% or for all parameters at once.
%    object=bound(object,table); % two-column table of min/max values
% Minimum and maximum bounds must be specified in both cases.
%
% Positive and negative infinity indicate parameters that are unbounded in a
% particular direction.  This leads to four types of parameter bound.
%    (1) [-inf +inf] indicates completely unbounded parameters.
%    (2) [-inf b] indicates parameters bounded by a maximum value.
%    (3) [a +inf] indicates parameters bounded by a minimum value.
%    (4) [a b] indicates parameters bounded by a minimum and maximum value.
% Paramaters that fall outside the specified bounds are automatically
% moved inside; a warning is also generated.
%
% See also BoundParameter
%

%
% created September 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=bound(object,varargin)

% save previous state
param=object.Parameter;

% manage input
switch numel(varargin);
    case 1    
        table=varargin{1};
        assert(isnumeric(table) && all(size(table)==size(object.Bound)),...
            'ERROR: invalid bound array');
        table=sort(table,2);
        assert(all(diff(table,[],2) > 0),'ERROR: invalid bound array');
    case 2                
        index=varargin{1};
        value=varargin{2};
        table=object.Bound; 
        try
            table(index,:)=value;
            object=bound(object,table);
        catch
            error('ERROR: invalid bound index/value');
        end
        return       
    otherwise
        error('ERROR: invalid number of inputs');
end
object.Bound=table;

% test parameters against new bounds
flag=false;
for n=1:object.NumberParameters
    bnd=object.Bound(n,:);
    if (param(n) < bnd(1)) || (param(n) > bnd(2))     
        param(n)=nan;
        flag=true;
    end
end
if flag
    warning('SMASH:BoundParameter','Parameter(s) moved inside bounds');
end

object.Parameter=param;
slack=object.Slack;
slack(isnan(slack))=0;
object.Slack=slack;

end