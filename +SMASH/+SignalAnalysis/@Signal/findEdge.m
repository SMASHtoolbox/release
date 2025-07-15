% findEdge Find pulse edge
%
% This method finds the edge of a rising/falling pulse in a signal object.
%    location=findEdge(object,name,value,...);
% Edge analysis is controlled by optional name/value pairs.
%    -'Derivative' defines the derivative level (default is 1).  Allowed
%    values are 1 or 2.
%    -'Duration' defines horizontal smoothing in grid units.  By default,
%    signals are smoothed over five grid points.  Larger durations
%    increase the number of smoothing points based on sample spacing,
%    always rounding up to an odd number of smoothing points.
%    -Direction' indicates the edge type.  The default value is 'any',
%    which looks for the strongest edge in any direction.  This option can
%    also be set to 'rising' or 'falling'.
%
% See also Signal
%
function varargout=findEdge(object,varargin)

% manage input
option=struct('Duration',[],'Derivative',1,'Direction','any');
option=SMASH.Developer.options2struct(option,varargin{:});

if isempty(option.Duration)
    nhood=5;
else
    time=object.Grid;
    dt=abs(time(end)-time(1))/(numel(time)-1);
    try
        nhood=ceil(option.Duration/dt);
        assert(isscalar(nhood) && (nhood > 0));
    catch
        error('ERROR: smoothing duration must be a number > 0');
    end
end

level=option.Derivative;
assert(isnumeric(level) && isscalar(level) && any(level == [1 2]),...
    'ERROR: derivative level must be 1 or 2')

direction=option.Direction;
assert(ischar(direction),'ERROR: invalid direction');
direction=lower(direction);
switch direction
    case {'any' 'rising' 'falling'}
        % keep going
    otherwise
        error('ERROR: direction must be ''any'', ''rising'', or ''falling''');
end

% analysis
source=differentiate(object,[1 nhood],level);
switch direction
    case 'any'
        [~,index]=max(abs(source.Data));
        label='Edge';
    case 'rising'
        [~,index]=max(source.Data);
        label='Rising edge';
    case 'falling'
        [~,index]=max(-source.Data);
        label='Falling edge';
end
location=source.Grid(index);

% manage output
if nargout == 0
    view(object);
    xline(location,'Color','r');    
    label=sprintf('%s at %g (derivative %d)',label,location,level);
    title(label);
else
    varargout{1}=location;
    varargout{2}=nhood;
end

end