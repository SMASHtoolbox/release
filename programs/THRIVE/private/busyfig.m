% busyfig : control a figure's busy state
%
% This function provides a "busy" state for use within a callback in situations
% where a waitbar may not be appropriate.  For example, a figure could be made 
%  busy while data is loaded from a file to prevent further actions.  When the
%  process is complete, the busy state can be turned off to resume normal
%  operations.
%
% busyfig(fig,'on'); % activates the busy state
% busyfig(fig,'off'); % disables the busy state
%
% It is assumed the busy state is turned on and then off for particular figure
% before moving on to other figures.

% created 1/16/2008 by Daniel Dolan
function busyfig(fig,state)

persistent data

if ~ishandle(fig) || ~strcmpi(get(fig,'Type'),'figure')
    error('ERROR: specified handle is not a figure');
end

switch lower(state)
    case 'on'
        data.ptr=getptr(fig);
        setptr(fig,'watch');
    case 'off'
        set(fig,data.ptr{:});
end

