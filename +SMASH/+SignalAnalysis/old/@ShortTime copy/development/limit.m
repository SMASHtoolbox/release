% limit Limit object to a region of interest
%
% This method is a special implementation of "limit" method for ShortTime
% objects.  It works in the same manner and then updates partitioning as
% needed.
%
% See also ShortTime, Signal.limit
%

%
% created December 15, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function varargout=limit(object,varargin)

if nargin==1
    varargout=cell(1,nargout);
    [varargout{:}]=limit@SMASH.SignalAnalysis.Signal(object);
    return
end

object=limit@SMASH.SignalAnalysis.Signal(object,varargin{:});
switch object.Partition.Choice
    case 'blocks' % apply relative setting
        value=nan(1,2);
        value(1)=object.Partition.Blocks;
        value(2)=object.Partition.Overlap;
        object=partition(object,'blocks',value);
    otherwise
        % do nothing--absolute settings are in use
end
varargout{1}=object;

end