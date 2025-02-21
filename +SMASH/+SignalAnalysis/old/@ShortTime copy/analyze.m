% ANALYZE Apply local analysis
%
% This method applies a target function to local regions in a ShortTime
% object.
%    >> result=analyze(object,target);
% The target function should be passed as a function handle.  Inline
% functions can be used:
%    >> target=@(x,y) mean(y); % local mean
%    >> target=@(x,y) sqrt(mean(y.^2)); % local RMS
% Function files, such as target=@myfunction, can also be used so long as
% the function accepts two inputs and returns a single output.  The inputs
% are column arrays whose length matching object's the "points" parameter;
% function's output can be a scalar or one-dimenional array.  The method's
% output "result" is a SignalGroup object, with function evaluations stored
% in the Data property and regional time centers stored in the Grid
% property.
%
% This method automatically manages parallel processing as available.  If
% multiple MATLAB workers are present, regional evaluations are managed
% with a parallelized "parfor" loop; otherwise, a standard "for" loop is
% used.  Due to differences in how these loops may be evaluated, the target
% function should *not* rely on evaluation order!
%
% See also ShortTime, partition
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=analyze(object,target_function)

% handle input
if (nargin<2) || isempty(target_function)
    target_function=@(x,y) y;
end
%assert(nargin==2,'ERROR: no target function specified');
if ischar(target_function)
    target_function=str2func(target_function);
end
if ~isa(target_function,'function_handle')
    error('ERROR: invalid target function');
end

% analyze region of interest
if ~strcmpi(object.LimitIndex,'all')
    object.Grid=object.Grid(object.LimitIndex);
    object.Data=object.Data(object.LimitIndex);
    object.LimitIndex='all';
end

if isempty(object.Partition)
    warning('SMASH:ShortTime',...
        'No partitioning specified--using 10 blocks with 0 overlap');
    object=partition(object,'blocks',[10 0]);
end
points=object.Partition.Points;
skip=object.Partition.Skip;

time=object.Grid;
numpoints=numel(time);
right=points:skip:numpoints;
left=right-points+1;
time=(time(left)+time(right))/2;
Niter=numel(time);

% analyze the first block
local=constructLocal(object,left(1),right(1));
try
    temp=feval(target_function,local.Grid,local.Data);
catch exception
    message{2}='* Target function error *';
    message{3}=repmat('*',size(message{2}));
    message{1}=message{3};
    fprintf('%s\n',message{:});
    throw(exception)
end
data=nan(numel(temp),Niter);
data(:,1)=temp(:);

% analyze remaining blocks
parallel=false;
try
    if exist('matlabpool','file') && (matlabpool('size')>0) %#ok<DPOOL>
        parallel=true; % MATLAB 2013a and earlier
    end
catch
    if ~isempty(gcp('nocreate'))
        parallel=true; % MATLAB 2014a and later
    end
end

if parallel
    fprintf('Performing analysis...');
    parfor k=2:Niter
        local=constructLocal(object,left(k),right(k));
        temp=feval(target_function,local.Grid,local.Data);
        data(:,k)=temp(:);
    end
    fprintf('done!\n');
else
    fprintf('Performing analysis...');
    for k=2:Niter
        local=constructLocal(object,left(k),right(k));
        temp=feval(target_function,local.Grid,local.Data);
        data(:,k)=temp(:);
    end
    fprintf('done!\n');
end

% handle output
data=transpose(data);
result=SMASH.SignalAnalysis.SignalGroup(time,data);
result.GridLabel=object.GridLabel;
if nargout==0
    view(result);
else
    varargout{1}=result;
end

end

function object=constructLocal(object,left,right)

array=left:right;
object.Grid=object.Grid(array);
object.Data=object.Data(array);
object.LimitIndex='all';

end
