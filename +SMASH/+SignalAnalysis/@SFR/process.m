% hidden method
%
% This method manages serial/parallel process for the preview and reduce
% methods.
function result=process(object,routine)

% manage parallel calculations
workers=1;
if strcmp(object.LoopMode,'parallel')
    pool=gcp('nocreate');
    if isempty(pool)
        warning('No worker pool available--defaulting to serial mode');
    else
        workers=pool.NumWorkers; % parallel mode
    end
else
    
end

% prepare data
time=object.Time;
report=setTimeScale(object);

StepStop=report.DurationPoints:report.StepPoints:numel(time);
StepStart=StepStop-report.DurationPoints+1;
StepsPerWorker=ceil(object.TotalSteps/workers);
tcenter=nan(StepsPerWorker,workers);
tcenter(1:numel(StepStop))=(time(StepStart)+time(StepStop))/2;

data=nan(StepsPerWorker,workers);
column=1;
for step=1:object.TotalSteps  
    if (step < object.TotalSteps) && (rem(step,StepsPerWorker) > 0)
        continue
    end
    k1=StepStart(1);
    if numel(StepStop) >= StepsPerWorker
        k2=StepStop(StepsPerWorker);        
    else
        k2=StepStop(end);   
    end
    section=object.Signal(k1:k2);
    data(1:numel(section),column)=section;    
    column=column+1;
    StepStart=StepStart(StepsPerWorker+1:end);
    StepStop=StepStop(StepsPerWorker+1:end);
end

% perform local calculations
out=cell(1,workers);
if numel(workers) == 1
    for k=1:workers
        out{k}=feval(routine,tcenter(:,k),data(:,k));
    end
else
    parfor k=1:workers
        out{k}=feval(routine,tcenter(:,k),data(:,k));
    end
end

% collect results
result=vertcat(out{:});
result=sortrows(result,[1 2]);

end