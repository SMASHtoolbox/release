% ANALYZE Perform local analysis
%
% This method applies a target function to local regions in a ShortTime
% object.
%    result=analyze(object,target);
% Target functions must accept one input and return at least one output.
% The function's output is collected from each local region and returned as
% a SignalGroup object ("result");
% 
% Local regions are passed as Signal objects to the target function.  The
% "Grid" and "Data" properties of this object hold the information for
% local analysis.  The following example illustrates a local median
% calculation.
%    result=analyze(object,@(local) median(local.Data));
% Function files can be be used for more involved calculations.
%    function out=myfunc(local)
%       out=nan(2,1);
%       out(1)=median(local.Data);
%       out(2)=variance(local.Data);
%    end
%    result=analyze(object,@myfunc);
% Any function that accepts a Signal function as its first input and
% returns a numeric array can be used as a local function.  The target
% function can use additional inputs only if they are optional: the
% statement "out=myfunc(local)" must be valid.  Functions with multiple
% outputs are also acceptible, but only the first is used by this method.
%
% Numeric output from the local function ("out") can be an array of any
% size.  Each element of this array forms one signal in a SignalGroup
% object.  Local region centers are the time base for this object.
%
% Local analysis is performed serially by default, starting from the first
% block.  When multiple MATLAB workers are present *and* parallel analysis
% is requested:
%    result=analyze(object,target,'parallel');
% local analysis is distributed across the worker pool.  The target
% function should not assume that analysis blocks are passed sequentially
% in parallel calculations!
%
% See also SMASH.SignalAnalysis.ShortTime, partition, SMASH.SignalAnalysis.Signal, SMASH.SignalAnalysis.SignalGroup
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised July 1, 2016 by Daniel Dolan
%    -converted local information to Signal objects
%
function varargout=analyze(object,target_function,mode)

% handle input
if (nargin<2) || isempty(target_function)
    warning('SMASH:ShortTime','No target function specified--using local mean');
    target_function=@(local_obj) mean(local_obj.Data);
end
if ischar(target_function)
    target_function=str2func(target_function);
end
assert(isa(target_function,'function_handle'),...
    'ERROR: invalid target function')

if (nargin < 3) || isempty(mode)
    mode='serial';
else
    assert(ischar(mode),'ERROR: invalid analysis mode');
    mode=lower(mode);
    switch mode
        case 'serial' 
            % keep going
        case 'parallel'
            if ~SMASH.System.isParallel
                warning('Parallel computation not available/enabled--using serial analysis');
            end
        otherwise
            error('ERROR: analysis mode must be ''parallel'' or ''serial''');
    end
end

% determine region of interest
[time,~]=limit(object.Measurement);
numpoints=numel(time);

points=object.Partition.Points;
skip=object.Partition.Skip;

right=points:skip:numpoints;
left=right-points+1;
tcenter=(time(left)+time(right))/2;
Niter=numel(tcenter);

% set up block analysis
LocalFunction=@(index) analyzeBlock(object,index,target_function);

% analyze the first block
try
    temp=LocalFunction(left(1):right(1));
catch exception
    message{2}='* Target function error *';
    message{3}=repmat('*',size(message{2}));
    message{1}=message{3};
    fprintf('%s\n',message{:});
    throw(exception)
end
data=nan(numel(temp),Niter);
data(:,1)=temp(:);

if strcmpi(object.ProgressReport,'none')
    updateReport=[];
else    
    label=sprintf('%s analysis: ',object.Name);
    updateReport=SMASH.MUI.trackLoop(Niter,label,object.ProgressReport);
    updateReport();
end

% analyze remaining blocks  
if SMASH.System.isParallel && strcmpi(mode,'parallel')
    parfor k=2:Niter                  
        data(:,k)=LocalFunction(left(k):right(k));
        if ~isempty(updateReport)
            updateReport();
        end
    end    
else
    for k=2:Niter
        data(:,k)=LocalFunction(left(k):right(k));    
        if ~isempty(updateReport)
            updateReport();
        end
    end    
end

% handle output
data=transpose(data);

result=SMASH.SignalAnalysis.SignalGroup(tcenter,data);
result.GridLabel=object.Measurement.GridLabel;
result.DataLabel='Result';
label=cell(result.NumberSignals,1);
for n=1:result.NumberSignals
    label{n}=sprintf('Result %d',n);
end
result.Legend=label;
result=verifyGrid(result);

if nargout==0
    view(result);
else
    varargout{1}=result;
end

end

%%
function out=analyzeBlock(object,index,target_function)

persistent local
if isempty(local)
    local=SMASH.SignalAnalysis.Signal([],nan(1,2));
    local.GridLabel=object.Measurement.GridLabel;
    local.DataLabel=object.Measurement.DataLabel;
    local.Name='Local signal'; 
    local.GraphicOptions.Title=object.Measurement.GraphicOptions.Title;
end

local=reset(local,object.Measurement.Grid(index),object.Measurement.Data(index));
out=target_function(local);
out=out(:);

end