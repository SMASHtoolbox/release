% PermanentPreference(name,value); % set
% value=PermanentPreference(name); % get
%
% data=PermanentPreference(); % reveal settings
% PermanentPreference(name,[],'remove'); % remove setting

function varargout=PermanentPreference(varargin)

% reveal mode
if nargin==0
    varargout{1}=getpref('SMASHtoolbox');
    if isempty(varargout{1})
        varargout{1}=struct();
    end
    return
end

% get/set modes
name=varargin{1};
assert(isvarname(name),'ERROR: invalid setting name');

if nargin==1 % get preference
    assert(ispref('SMASHtoolbox',name),'ERROR: invalid setting name');
    varargout{1}=getpref('SMASHtoolbox',name);
elseif nargin==2 % set preference
    setpref('SMASHtoolbox',name,varargin{2});
elseif nargin==3 && strcmpi(varargin{3},'remove') % remove preference
    if ispref('SMASHtoolbox',name);
        rmpref('SMASHtoolbox',name);
    end
else
    error('ERROR: invalid input');
end

end