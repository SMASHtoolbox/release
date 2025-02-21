% identifyRegions Identify distinct regions
%
% This *static* method identifies distinct regions in a logical array.
%    bound=SFR.identifyRegions(array,nhood);
% The input "nhood" indicates the minimum neighborhood size for identifying
% distinct regions.  False array values become true inside the neighborhood
% of a true value, starting with the specified size.  The neighborhood size
% is incrementally increased until the number of distinct regions
% stabilizes.  This process coalesces nearby true regions separated by
% a few false vaues into continuous regions.
%
% The output "bound" is a two-column array of region indices.  Each row of
% this array indicates the start and stop index for one distinct region,
% which is defined by a continuous group of true values.
%
% See also SFR
%
function bound=identifyRegions(array,nhood)

assert(nargin >= 2,'ERROR: insufficient input');
assert(islogical(array),'ERROR: invalid logical array');
N=numel(array);

ERRMSG='ERROR: invalid neighborhood size';
assert(testNumber(nhood),ERRMSG);
nhood=ceil(nhood);
assert((nhood > 0) && (nhood <= N),ERRMSG);

% stabilize number of regions
previous=countRegions(array); % previous block counter
for iteration=nhood:N
    kernel=ones(iteration,1);
    newflag=conv2(array(:),kernel,'same');
    current=countRegions(newflag > 0);
    if current == previous
        break
    end
    previous=current;
end
    function value=countRegions(array)
        change=array(2:end)-array(1:end-1);
        value=sum(change > 0);
        if array(1)
            value=value+1;
        end
    end

% find region boundaries
bound=nan(current,2);
index=1:N;
for k=1:current
    start=find(newflag,1,'first');
    bound(k,1)=index(start);
    newflag=newflag(start+1:end);
    index=index(start+1:end);
    stop=find(~newflag,1,'first');
    if isempty(stop)
        stop=numel(newflag);
    else
        stop=stop-1;
    end
    bound(k,2)=index(stop);
    newflag=newflag(stop+1:end);
    index=index(stop+1:end);
end

end