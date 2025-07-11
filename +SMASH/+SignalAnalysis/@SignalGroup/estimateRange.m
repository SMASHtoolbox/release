% estimateRange Estimate signal range
%
% This method estimates the minimum and maximum values of a signal based on
% local averaging over a specified duration.
%    [range,uncertainty]=estimateRange(object,duration);
% The input "duration" must be larger than signal's grid spacing.  The
% output "range" is two-column array of minimum and maximum values; the
% output "uncertainty" is the estimated range value.
%
% NOTE: estimates are strongly influenced by duration!  Signal variations
% on similar or faster time scales may bias the results.
%
% See also SignalGroup
%

%
% created April 26, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function [range,uncertainty]=estimateRange(object,duration)

try
    [range,uncertainty]=estimateRange(split(object,1),duration);
catch ME
    throwAsCaller(ME);
end

range=repmat(range,object.NumberSignals,1);
uncertainty=repmat(uncertainty,object.NumberSignals,1);

for k=2:object.NumberSignals
    [range(k,:),uncertainty(k,:)]=estimateRange(split(object,k),duration);    
end

end