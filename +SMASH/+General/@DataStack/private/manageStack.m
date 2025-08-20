% Valid modes:
%    manageStack('push',name,value);
%
%    value=manageStack('pop',name);
%
%    list=manageStack('probe',name);
%
%    manageStack('delete',name,...);
%
function varargout=manageStack(mode,varargin)

mlock
persistent StackMemory
if isempty(StackMemory)
    StackMemory=struct();
end

if strcmp(mode,'push')
    name=varargin{1};
    value=varargin{2};
    if ~isfield(StackMemory,name)
        StackMemory.(name)={};
    end
    StackMemory.(name){end+1}=value;
    return
end

switch mode       
    case 'pop'
        name=varargin{1};
        msg=sprintf('ERROR: stack "%s" not defined',name);
        assert(isfield(StackMemory,name),msg);
        if isempty(StackMemory.(name))
            varargout{1}=[];
        else
            varargout{1}=StackMemory.(name){end};
        end
        StackMemory.(name)=StackMemory.(name)(1:end-1);
    case 'probe'
        if nargin == 1
            varargout{1}=fieldnames(StackMemory);
        else
        name=varargin{1};
        msg=sprintf('ERROR: stack "%s" not defined',name);
        assert(isfield(StackMemory,name),msg);
            varargout{1}=numel(StackMemory.(name));
        end
    case 'delete'
        if nargin == 1
            StackMemory=struct();
        else
        name=varargin{1};
        msg=sprintf('ERROR: stack "%s" not defined',name);
        assert(isfield(StackMemory,name),msg);
            StackMemory=rmfield(StackMemory,name);
        end
end

end