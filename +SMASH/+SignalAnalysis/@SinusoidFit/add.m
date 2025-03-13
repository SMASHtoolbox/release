% add Add sinusoid
% 
% This method adds a new component to the sinusoid fit.  Component location
% is determined automatically from the strongest residual location.
%    add(object);
% Component location can also be specified manaully
%    add(object,location); 
% The input "location" must be a numeric scalar.
%
% See also SinusoidFit, move, remove
%

%
% created February 22, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function add(object,value)

% manage input
if (nargin < 2) || isempty(value)        
    full=split(object.Spectrum,2);
    temp=abs(full.Data);
    [~,index]=max(temp);
    value=full.Grid(index);
else
    assert(isnumeric(value) && isscalar(value),...
        'ERROR: invalid frequency value');
end

object.Parameter(end+1,:)=[value nan nan];
object.NumberSinusoids=size(object.Parameter,1);
scaleBasis(object);

end