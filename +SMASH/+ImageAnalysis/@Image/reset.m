% RESET Reset Grid and Data properties
%
% This method resets the Grid and Data stored in an Image object.  Arrays
% can be passed directly into the object:
%    >> object=reset(object,Grid1,Grid2,Data);
% where grid1, grid2, and data are arrays of consistent size; passing an
% empty array preserves the existing array.
%    >> object=reset(object,[],[],Data); % preserve original grids
%    >> object=reset(object,Grid1,[],[]); % change first grid 
% Grid and Data information can also be reset using a source object.
%    >> object=reset(object,source);
%
% See also Image, replace
%

%
% created June 12, 2015 by Daniel Dolan (Sandia National Laboratory)
%
function object=reset(object,varargin)

% manage input
Narg=numel(varargin);
assert(any(Narg==3), 'ERROR: invalid number of inputs');

if isa(varargin{1},'SMASH.ImageAnalysis.Image')
    Grid1=varargin{1}.Grid1;
    Grid2=varargin{1}.Grid2;
    Data=varargin{1}.Data;
    object=reset(object,Grid1,Grid2,Data);
    return    
end
Grid1=varargin{1};
Grid2=varargin{2};
Data=varargin{3};

% manage empty arrays
if isempty(Grid1)
    Grid1=object.Grid1;
end

if isempty(Grid2)
    Grid2=object.Grid2;
end

if isempty(Data)
    Data=object.Data;
end

% transfer inputs to object
assert(numel(Grid1)==size(Data,2) && numel(Grid2)==size(Data,1),...
    'ERROR: inconsistenct Grid/Data arrays');
object.Grid1=reshape(Grid1,[1 numel(Grid1)]);
object.Grid2=reshape(Grid2,[numel(Grid2) 1]);
object.Data=Data;
object=limit(object,'all');

object=updateHistory(object);

end