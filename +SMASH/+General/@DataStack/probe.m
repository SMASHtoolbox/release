% probe Probe data stacks
%
% This method probes existing data stacks.  When called without input:
%    list=DataStack.probe();
% the name of all data stacks is returned as a cell array of strings
% (output "list").  Passing a defined stack name:
%    N=DataStack.probe(name);
% returns the number of layers in that stack.
%
% See also DataStack, push, pop, delete
%

%
% created November 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=probe(name)

if nargin == 0
   value=manageStack('probe');
else
    try
        value=manageStack('probe',name);
    catch ME
        throwAsCaller(ME);
    end
end

if nargout == 0
    if isnumeric(value)
        fprintf('Stack "%s" contains %d layers\n',name,value)
    else
        if isempty(value)
            fprintf('No stacks defined\n');
        else
            fprintf('Defined stacks:\n');
            fprintf('   %s\n',value{:});
        end
    end
else    
    varargout{1}=value;
end

end