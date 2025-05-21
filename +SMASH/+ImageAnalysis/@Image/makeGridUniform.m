% makeGridUniform Enforce uniform Image grid
%
%    >> object=makeGridUniform(object);
%
% See also Image
%

%
% created November 20, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=makeGridUniform(object)

if object.Grid1Uniform && object.Grid2Uniform
    return
end

persistent AutoRegrid
if isempty(AutoRegrid)
    AutoRegrid=false;
elseif AutoRegrid
    object=regrid(object);
    return
end

% ask user to regrid
callstack=dbstack('-completenames');
name=callstack(2).name;

fig=SMASH.MUI.Dialog;
fig.Hidden=true;
fig.Name='Regrid object';

message=sprintf(...
    ['This object has a non-uniform grid, but the "%s" method requires a uniform grid. '...
    'Should the object be mapped onto a uniform grid?'],name);
message=textwrap({message},50);
addblock(fig,'Text',message);
button=addblock(fig,'Buttons',{' yes ',' no '});
choice='no';
set(button,'Callback',@PushButton)
    function PushButton(src,varargin)
        choice=strtrim(get(src,'String'));
        fig.Modal=false;
    end
addblock(fig,'CheckBox','Always regrid');

locate(fig,'center');
fig.Hidden=false;
fig.Modal=true;
waitfor(fig.Handle,'WindowStyle');

if strcmpi(choice,'no')
    delete(fig);
    error('ERROR: uniform grid required');
end
object=regrid(object);

choice=probe(fig);
AutoRegrid=logical(choice{1});
delete(fig);

end