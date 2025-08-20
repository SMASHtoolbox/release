% analyze Perform local analysis
%
% This method analyzes local partitions of a LongSignal object.  The
% precise analysis is defined by a function handle:
%    result=analyze(object,LocalFcn);
% that accepts a SignalGroup object and returns a numeric array.  The
% output "result" is a SignalGroup object constructed from the local
% function output from each partition.
%
% Local analysis is performed over the entire grid by default.  A
% limited grid range can also be specified.
%    result=analyze(object,LocalFunc,[start stop]);
%    result=analyze(object,LocalFunc,[-inf stop]);
%    result=analyze(object,LocalFunc,[start +inf]);
% Start values at negative infininty cause analysis to begin on the left
% side of the gird; stop values at positive infinity cause analysis to stop
% on the right side.  An empty range uses the full grid.
%
% Analysis updates are printed to the command window at 1% intervals by
% default.  Custom progress updates can also be specified.
%    result=analyze(object,LocalFcn,range,update);
% The input "update" indicates the progress change (in percent) before the
% command window is updated.  Any value greater than zero is permitted, but
% values greater than 100 suppress status updates.
%
% See also LongSignal, partition
%

%
% created May 26, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function result=analyze(object,LocalFcn,range,update)

assert(~isempty(object.Partition),...
    'ERROR: cannot analyze until object is partitioned');

% manage input
assert(nargin >= 2,'ERROR: no local function specified');
assert(isa(LocalFcn,'function_handle'),...
    'ERROR: invalid target function')

if (nargin < 3) || isempty(range)
    range=[-inf inf];
else
    errmsg='ERROR: invalid analysis range';
    assert(isnumeric(range) && (numel(range) == 2),errmsg);
    range=sort(range);
    assert(diff(range) > 0,errmsg);
end

if (nargin < 4) || isempty(update)
    update=1;
else
    assert(SMASH.General.testNumber(update,'positive','notzero'),...
        'ERROR: invalid status value');
end

% local calculations
tstart=object.Start;
tstop=object.Stop;
tincrement=object.Increment;

range(1)=max(range(1),tstart);
index(1)=ceil((range(1)-tstart)/tincrement)+1;

range(2)=min(range(2),tstop);
index(2)=floor((range(2)-tstart)/tincrement)+1;

LR=(object.Partition.Points-1)/2; % points left/right of center
center=(index(1)+LR):object.Partition.Skip:(index(2)-LR);
N=numel(center);
tcenter=nan(1,N);

OldStatus=0;
count=0;
if update <= 100
    if update >= 1
        format='Analysis is %2.0f%% complete';
    else
        format=abs(floor(log10(update/100)));    
        format=sprintf('Analysis is %%%d.%df%%%% complete',format+1,format-2);
    end    
    count=fprintf(format,0);
end

for n=1:N
    tcenter(n)=tstart+(center(n)-1)*tincrement;
    range=center(n)+[-1 1]*LR;    
    block=readFile(object,range,'quick');
    try
        temp=LocalFcn(block);
    catch exception
        fprintf(2,'\n');
        fprintf(2,'*********************\n')
        fprintf(2,'LOCAL FUNCTION ERROR\n')
        fprintf(2,'*********************\n')
        throwAsCaller(exception)
    end
    if n == 1
        data=nan(numel(temp),N);       
    end
    data(:,n)=temp(:); 
    NewStatus=(n/N)*100;
    if (NewStatus-OldStatus) >= update
        fprintf(repmat('\b',[1 count]));
        count=fprintf(format,NewStatus);
        OldStatus=NewStatus;
    end
end

if update <= 100
    fprintf(repmat('\b',[1 count]));
    fprintf('Analysis is complete\n');
end

% collect results
data=transpose(data);
result=SMASH.SignalAnalysis.SignalGroup(tcenter,data);

end