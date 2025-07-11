% selectReference Select reference region
%
% This method selects the reference region, which is used in frequency
% offset and noise calculations.
%    object=selectReference(object,[start stop]); % manual specification
%    object=selectReference(object); % interactive selection with new figure
%    object=selectReference(object,target); % interactive selection on target axes object(s)
% The reference region should be as large as possible and contain only
% static frequencies.
%
% See also PDV, calculateOffset, calculateNoise
%

%
% created February 9, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=selectReference(object,value)

% manage input
if (nargin < 2) || isempty(value)
    region=SMASH.ROI.Rectangle('x');
    if ~isempty(object.ReferenceSelection)
        region=define(region,object.ReferenceSelection);
    end
    region.Name='Reference selection';    
    [~,target]=view(object,'spectrogram');
    fig=gcf;
    region=select(region,target);
    value=region.Data;
    delete(fig);
elseif all(ishandle(value))    
    region=SMASH.ROI.Rectangle('x');
    if ~isempty(object.ReferenceSelection)
        region=define(region,object.ReferenceSelection);
    end
    region.Name='Reference selection';
    region=select(region,value);
    value=region.Data;
else
    errmsg='ERROR: invalid reference selection';
    assert(isnumeric(value) && (numel(value)==2),errmsg);
    value=sort(value);
    assert(diff(value) > 0,errmsg);    
end

% store value and update status
object.ReferenceSelection=value;

object=changeStatus(object,'obsolete','noise','history');
object.Status.Reference='complete';

end