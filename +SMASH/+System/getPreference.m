% getPreference Get toolbox preferences
%
% This function gets preferences associated with the SMASH toolbox.
% Specific preferences are accessed by name.
%    value=getPreference(name);
% Omitting the name returns a structure containing all preferences
%    value=getPreference();
%
% Preference values are displayed in the command window if no output is
% specified.
%    getPreference(...);
%
%
% See also System, setPreference
%

%
% created November 11, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=getPreference(name,mode)

% manage input
if (nargin<2) || isempty(mode)
    mode='alert';
end

% search preferences
type='';
if nargin==0
    value.Workspace=WorkspacePreference();
    value.Session=SessionPreference();
    value.Permanent=PermanentPreference();
else
    assert(isvarname(name),'ERROR: invalid preference name');
    try
        value=WorkspacePreference(name);
        type='workspace';
    catch
        try
            value=SessionPreference(name);
            type='session';
        catch
            try
                value=PermanentPreference(name);
                type='permanent';
            catch
                if strcmpi(mode,'alert')
                    error('ERROR: requested preference is not defined');
                else
                    value=[];
                end
            end
        end
    end
end

% manage output
if nargout==0
    if nargin==0
        fprintf('Workspace preferences:\n');
        printStructure(value.Workspace);
        fprintf('Session preferences:\n');
        printStructure(value.Session);
        fprintf('Permanent preferences:\n');
        printStructure(value.Permanent)
    else
        disp(value);
    end
else
    varargout{1}=value;
    varargout{2}=type;
end

end

function printStructure(data)

if isempty(fieldnames(data))
    fprintf('\n');
else
    disp(data);
end

end