% readDAS Read from a local/network DAS archive
%
% This function reads data acquisition system (DAS) archives stored locally
% or on a network drive.  These archives are collection of *.hdf files,
% each labeled by experiment number.  Four archive styles are currently
% supported:
%    -'c' or 'cmdas'   : standard Z archive
%    -'t' or 'tcwagon' : special Z archive
%    -'j' or 'jkmoore' : special Z archive
%    -'s' or 'saturn'  : standarn SATURN archive
%
% Archive locations are specified as:
%    >> readDAS('local',location);
%    >> readDAS('network',location);
% and persist throughout a MATLAB session.  If this function is used
% routinely, archive locations should be specified in the startup.m file.
% Settings are *not* lost when any form of the "clear" command is used.
% 
% To read from the archive, specify the experiment number, the signal
% label, and the archive style.
%    >> data=readDAS(shot,signal,style);
% The function looks for a local archive file, then searches for a
% network archive file.
%
% See also probeDAS

%
% created January 23, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function data=readDAS(varargin)

% check locations
DASlocation=struct('Local','','Network','');
if isappdata(0,'DASlocation')
    DASlocation=getappdata(0,'DASlocation');
end

% handle input
assert((nargin>0),'ERROR: invalid number of inputs');
if isnumeric(varargin{1}) && (nargin==3)
    shot=varargin{1};   
    signal=varargin{2};
    assert(ischar(signal),'ERROR: invalid signal name');  
    style=varargin{3};
    target=DASfile(shot,style);      
elseif strcmpi(varargin{1},'local') && (nargin==2)
    DASlocation.Local=varargin{2};
    assert(exist(DASlocation.Local,'dir')==7,...
        'ERROR: invalid local directory');    
    setappdata(0,'DASlocation',DASlocation);
    return
elseif strcmpi(varargin{1},'network') && (nargin==2)
    DASlocation.Network=varargin{2};      
    assert(exist(DASlocation.Network,'dir')==7,...
        'ERROR: invalid network directory');
    setappdata(0,'DASlocation',DASlocation);
    return
else
    error('ERROR: invalid input');
end

% read DAS file
switch lower(style)
    case {'s','saturn'}
        object=SMASH.FileAccess.DigitizerFile(target,'saturn');
    otherwise
        object=SMASH.FileAccess.DigitizerFile(target,'zdas');
end
data=read(object,signal);

end