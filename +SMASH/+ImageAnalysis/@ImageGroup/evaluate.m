% evaluate Evaluate user defined functions
%
% This method applies user defined functions to image group data.
%    new=evaluate(object,@myfunc); % single function
%    new=evaluate(object,@myfuncA,@myfuncB,...); % multiple functions
% The output "new" is an ImageGroup object containing one image for each
% requested function.  
%
%    <a href="matlab:SMASH.System.showExample('EvaluateExampleA','+SMASH/+ImageAnalysis/@ImageGroup')">Random example</a>
%
% See also ImageGroup, map
%

%
% created May 11, 2018 by Daniel Dolan(Sandia National Laboratories) 
%
function result=evaluate(object,varargin)

result=cell(1,numel(varargin));

for k=1:numel(varargin)
    assert(isa(varargin{k},'function_handle'),'ERROR: Invalid function');
    temp=feval(varargin{k},object.Data);
    result{k}=SMASH.ImageAnalysis.Image(object.Grid1,object.Grid2,temp);           
end

result=SMASH.ImageAnalysis.ImageGroup(result{:});
for k=1:result.NumberImages
    result.Legend{k}=sprintf('Result %d',k);
end

end