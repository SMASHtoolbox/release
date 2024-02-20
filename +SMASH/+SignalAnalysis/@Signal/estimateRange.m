% estimateRange Estimate signal range
%
% This method estimates the minimum and maximum values of a signal based on
% local averaging over a specified duration.
%    [range,uncertainty]=estimateRange(object,duration);
% The input "duration" must be larger than signal's grid spacing.  The
% output "range" is an array containing minimum and maximum values; the
% output "uncertainty" is the estimated range value.
%
% NOTE: estimates are strongly influenced by duration!  Signal variations
% on similar or faster time scales may bias the results.
%
% <a href="matlab:SMASH.System.showExample('RangeExample','+SMASH/+SignalAnalysis/@Signal')">Example</a>
%
% See also Signal
%

%
% created April 26, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function [range,uncertainty]=estimateRange(object,duration)

% enforce uniform grid
if ~object.GridUniform 
    object=regrid(object);
end
T=object.GridSpacing;

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(SMASH.General.testNumber(duration) && (duration > 3*T),...
    'ERROR: invalid duration');

% local smoothing
object=SMASH.SignalAnalysis.ShortTime(object);
object=partition(object,'Duration',[duration duration/2]);
result=analyze(object,@LocalFcn);

[range(1),index]=min(result.Data(:,1));
uncertainty(1)=result.Data(index,2);

[range(2),index]=max(result.Data(:,1));
uncertainty(2)=result.Data(index,2);

end

function out=LocalFcn(local)

out(1)=mean(local.Data);
out(2)=std(local.Data)/sqrt(numel(local.Data));

end