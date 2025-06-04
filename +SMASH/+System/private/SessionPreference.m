% SessionPreference(name,value); % set
% value=SessionPreference(name); % get
%
% data=SessionPreference(); % reveal settings
% SessionPreference(name,[],'remove'); % remove setting

function varargout=SessionPreference(varargin)

persistent data
if isempty(data)
    data=struct();
end
mlock

% reveal mode
if nargin==0
    varargout{1}=data;
    return
end

% get/set modes
name=varargin{1};
assert(isvarname(name),'ERROR: invalid setting name');

if nargin==1 % get preference
    assert(isfield(data,name),'ERROR: invalid setting name');
    varargout{1}=data.(name);
elseif nargin==2 % set preference
    data.(name)=varargin{2};
elseif nargin==3 && strcmpi(varargin{3},'remove') % remove preference
    if isfield(data,name)
        data=rmfield(data,name);
    end
else
    error('ERROR: invalid input');
end

end