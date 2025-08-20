% RESET Reset Grid/Data values 
%
% This method resets the Grid and Data stored in a SignalGroup object.  Arrays
% can be passed directly into the object:
%    >> object=replace(object,Grid,Data);
% where grid and data are arrays of consistent size.  Passing an empty
% array bypasses the reset.
%    >> object=replace(object,[],Data); % replace Data, preserve original Grid
%    >> object=replace(object,Grid,[]); % replace Grid, preserve original Data
% Grid and Data information can also be reset using a source object.
%    >> object=replace(object,source);
%
% See also SignalGroup, replace
%

% 
% created March 15, 2016 by Daniel Dolan (Sandia National Laboratories)
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
Data=varargin{2};

% manage empty arrays
if isempty(Grid)
    Grid=object.Grid;
end

if isempty(Data)
    Data=object.Data;
end

% transfer inputs to object
assert(numel(Grid)==size(Data,1),...
    'ERROR: inconsistenct Grid/Data arrays');
object.Grid=Grid;
object.Data=Data;
object=limit(object,'all');

if size(Data,2) ~= object.NumberSignals
    warning('SignalGroup:SizeChange',...
        'SignalGroup size changed during reset');
    object.NumberSignals=size(Data,2);
end
object=updateHistory(object);

end