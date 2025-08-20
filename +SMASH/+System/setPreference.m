% setPreference Set toolbox preference(s)
%
% This function sets preferences used by the SMASH toolbox.
%    setPreference(name,value);
% The input "name" must be a valid variable name: character strings
% beginning with a letter containing letters, numbers, and underscores only
% (case sensitive).  The input "value" can be any MATLAB variable
% understood by a particular feature in the toolbox.
%
% Several levels of preference persistence can be specified.  
%    setPreference(name,value,'workspace'); % default choice
%    setPreference(name,value,'session');
%    setPreference(name,value,'permanent');
% Workspace preferences remain in memory until the primary workspace is
% reset, typically by the "clear all" command.  Session preferences persist
% until the end of the current MATLAB session, while permanent preferences
% carry over to future sessions.  Persistance can be changed at any time by
% overwritting the preference value.
% 
% See also System, getPreference
%

%
% created November 11, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function setPreference(name,value,persist)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(isvarname(name),'ERROR: invalid preference name');

if (nargin<3) || isempty(persist)
    persist='session';
end
assert(ischar(persist),'ERROR: invalid persist value');

% store preference
switch lower(persist)
    case 'workspace'
        WorkspacePreference(name,value);
        SessionPreference(name,[],'remove');
        PermanentPreference(name,[],'remove');    
    case 'session'
        WorkspacePreference(name,[],'remove');
        SessionPreference(name,value);
        PermanentPreference(name,[],'remove');        
    case 'permanent'
        WorkspacePreference(name,[],'remove');
        SessionPreference(name,[],'remove');
        PermanentPreference(name,value);      
    otherwise
        error('ERROR: invalid persist value');
end

end