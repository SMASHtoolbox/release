% getMarker Get line marker
%
% This function gets a line marker by numerical index.
%    marker=getMarker(index);
% There are currently 15 valid line markers, so markers are repeated for
% larger values: 16 is marker 1, 17 is marker 2, and so forth.  The output
% "marker" is a character array for scalar index values and a cell array of
% characters for index arrays.  The command:
%    marker=getMarker('all');
% returns all valid line markers.
% 
% Omitting the index:
%    marker=getMarker();
% returning the next marker in the sequence.  An internal counter
% increments each time the function is called without an input.
%
% See also SMASH.Graphics.PlotTools
%
function [out,index]=getMarker(index)

persistent valid N previous
if isempty(valid)
    valid={'+','o','*','.','x','square','diamond',...
        'v','^','>','<','pentagram','hexagram','|','_'};
    N=numel(valid);
end
if isempty(previous)
    previous=0;
end

% manage input
if (nargin < 1) || isempty(index)
    index=previous+1;
elseif isnumeric(index)
    assert(all(index > 0) && all(isfinite(index)),...
        'ERROR: invalid marker index');
    index=round(index);
    index=rem(index,N);
    index(index == 0)=N;    
elseif strcmpi(index,'all')
    index=1:N;    
else
    error('ERROR: invalid marker index');
end

out=valid(index);
if isscalar(out)
    out=out{1};
end

previous=index(end);

end