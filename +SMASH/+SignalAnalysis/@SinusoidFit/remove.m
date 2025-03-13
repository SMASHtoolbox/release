% UNDER CONSTRUCTION
% remove Remove sinusoid
%
% This method removes one or more components from a sinusoid fit.
%    remove(object,index);
% The input "index" can be an integer or array of integers indicating the
% component(s) to be removed.  To remove all components:
%    remove(object,'all');
%
% See also SinusoidFit, add, move
%

%
% created February 22, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function remove(object,index)

% manage input
assert(nargin > 1,'ERROR: no sinusoid index given');
valid=1:object.NumberSinusoids;
if strcmpi(index,'all')
    index=valid;
else    
    assert(isnumeric(index) && isscalar(index),'ERROR: invalid sinusoid index');
    for k=1:numel(index)
        assert(any(index) == valid,'ERROR: invalid sinusoid index');
    end
end

% remove sinusoid
keep=true(1:object.NumberSinusoids);
for k=1:numel(index)
    keep(index(k))=false;
end
parameter=object.Parameter(keep,:);
object.Parameter=parameter;
object.NumberSinusoids=size(parameter,1);
scaleBasis(object);

end