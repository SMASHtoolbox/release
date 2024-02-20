% delete Delete stack(s)
%
% This method deletes one or more data stacks from memory.  Individual
% stacks should be deleted by name:
%    DataStack.delete(name); % individual stack
%    DataStack.delete(name1,name2,...); % multipe stacks
%
% Calling the method with no input:
%    DataStack.delete();
% deletes *all* stacks from memory.  Since this may lead to unexpected
% results, the user is prompted to confirm deletion.
%
% See also DataStack, probe
%

%
% created November 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function delete(varargin)

if nargin == 0
    commandwindow();
    fprintf('Data stacks should be deleted individually\n');
    fprintf('Deleting them all at once may have unexpected results\n');
    choice=input('Are you sure you want to do this?  Type yes to continue: ','s');
    if strcmpi(choice,'yes')
        manageStack('delete');
    end
else
    for k=1:nargin
        name=varargin{k};
        assert(isvarname(name),'ERROR: invalid stack name');
        manageStack('delete',name);
    end
end

end