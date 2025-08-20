% EVALUATE Evaluate SignalGroup signals using user defined function(s)
%
% This method applies user defined function(s) on the SignalGroup data, 
% resulting in a new object.
%    >> new=evaluate(object,@myfunc);
%
% For example, to find the mean and standard deviation of the SignalGroup 
% signals:
%   >> new=evaluate(object,@(x) mean(x,2), @(x) std(x,[],2);
%
% See also SignalGroup, map
%

%
% created November 3, 2014 by Tommy Ao (Sandia National Laboratories) 
%
function result=evaluate(object,varargin)

output=[];

for k=1:numel(varargin)
    assert(isa(varargin{k},'function_handle'),'ERROR: Invalid function');
    temp=feval(varargin{k},object.Data);
    output=[output temp];
end

result=SMASH.SignalAnalysis.SignalGroup(object.Grid,output);


end

