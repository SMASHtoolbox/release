% combineHistory Combine history with another PDV object
%
% This method combines the history from a PDV object with another PDV
% object.
%    result=combineHistory(objectA,objectB);
% Combing objects with different settings emphasizes the narrower duration
% during acceleration and the wider duration in the steady state.  The
% output "result" is a SignalGroup object containing weighted averages of
% the velocity and uncertainty; the Comments property records the duration
% settings of the source objects.
%
% See also PDV, generateHistory, SMASH.SignalAnalysis.SignalGroup
%

%
% created February 21, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function result=combineHistory(wide,narrow)

% manage input
assert(nargin == 2,'ERROR: invalid number of inputs');

assert(strcmpi(wide.Status.History,'complete'),...
    'ERROR: wide history is not complete');

assert(isa(narrow,'SMASH.Velocimetry.PDV'),...
    'ERROR: invalid narrow object');
assert(strcmpi(narrow.Status.History,'complete'),...
    'ERROR: narrow history is not complete')

if wide.Partition.Points < narrow.Partition.Points
    result=combineHistory(narrow,wide);
    return
end

% extract results
result=gather(wide.History{1},narrow.History{1});

weight=split(result);
weight=limit(weight,'all');
weight=differentiate(weight,[1 wide.Partition.Points],1,'zero');
temp=abs(weight.Data);
temp(~isfinite(temp))=0;
weight=reset(weight,[],temp/max(temp));

result=evaluate(result,@weightedAverage);
    function out=weightedAverage(in)
        out=nan(size(in,1),2);
        out(:,1)=(1-weight.Data).*in(:,1)+weight.Data.*in(:,4);
        out(:,2)=(1-weight.Data).*in(:,2)+weight.Data.*in(:,5);
    end
result.GridLabel=wide.Label.Time;
result.Legend{1}=wide.Label.Velocity;
result.Legend{2}=wide.Label.Uncertainty;

% generate partition report
report{1}=sprintf('Wide duration: %g',wide.Partition.Duration);
report{2}=sprintf('Narrow duration: %g',narrow.Partition.Duration);
columns=0;
for m=1:numel(report)
    columns=max(columns,numel(report{m}));
end
format=sprintf('%%%ds',columns);

comment=char([]);
for m=1:numel(report)
   comment(end+1,:)=sprintf(format,report{m}); %#ok<AGROW>
end
result.Comments=comment;

end