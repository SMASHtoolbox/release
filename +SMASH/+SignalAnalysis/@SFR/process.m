% hidden method
%
% This method is a called by preview and reduce.  Its primary function is
% to manage parallel processing
function result=process(object,routine)

% manage parallel calculations
try %#ok<TRYNC>
    ps=parallel.Settings;
    ps.Pool.AutoCreate=false; % prevent parallel w/o existing workers
end

try
    pool=gcp('nocreate');
    assert(~isempty(pool));
    workers=pool.NumWorkers; % parallel mode
catch
    workers=1; % serial mode
end  

% prepare data
time=object.Time;

StepStop=object.FullPoints:object.StepPoints:numel(time);
StepStart=StepStop-object.FullPoints+1;
StepsPerWorker=ceil(object.TotalSteps/workers);
tcenter=nan(StepsPerWorker,workers);
tcenter(1:numel(StepStop))=(time(StepStart)+time(StepStop))/2;

data=nan(StepStop(StepsPerWorker),workers);
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
if strcmp(object.Mode,'debug')
    for k=1:workers % use serial loop for debugging
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