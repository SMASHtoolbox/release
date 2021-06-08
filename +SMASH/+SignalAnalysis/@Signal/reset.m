% RESET Reset Grid/Data values 
%
% This method resets the Grid and Data stored in a Signal object.  Arrays
% can be passed directly into the object:
%    >> object=reset(object,Grid,Data);
% where grid and data are arrays of consistent size.  Passing an empty
% array bypasses the reset.
%    >> object=reset(object,[],Data); % replace Data, preserve original Grid
%    >> object=reset(object,Grid,[]); % replace Grid, preserve original Data
% Grid and Data information can also be reset using a source object.
%    >> object=reset(object,source);
%
% See also Signal, replace
%

% 
% created July 11, 2014 by Daniel Dolan
% 
function object=reset(object,varargin)

% handle input
Narg=numel(varargin);
assert((Narg==1) || (Narg==2),...
    'ERROR: invalid number of inputs');

if isa(varargin{1},'SMASH.SignalAnalysis.Signal')
    Grid=varargin{1}.Grid;
    Data=varargin{1}.Data;
    object=reset(object,Grid,Data);
    return    
end
Grid=varargin{1}(:);
Data=varargin{2}(:);

% manage empty arrays
if isempty(Grid)
    Grid=object.Grid;
end

if isempty(Data)
    Data=object.Data;
end

% transfer inputs to object
assert(numel(Grid)==numel(Data),...
    'ERROR: inconsistenct Grid/Data arrays');
object.Grid=Grid;
object.Data=Data;
object=limit(object,'all');

%object=updateHistory(object);

end