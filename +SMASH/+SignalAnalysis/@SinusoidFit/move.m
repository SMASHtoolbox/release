% move Move sinusoid
%
% This method moves one component in a sinusoid fit.
%    move(object,value,index);
% The input "value" is the updated frequency location of the compnent
% specified by "index".  Omitting the last argument automatically moves the
% first component.
%
% See also SinusoidFit, add, remove
%

%
% created February 22, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function move(object,value,index)

assert(object.NumberSinusoids > 0,'ERROR: no sinusoids defined');

% manage input
assert(nargin > 1,'ERROR: insufficient input');
assert(isnumeric(value) && isscalar(value),'ERROR: invalid frequency');

if (nargin < 3) || isempty(index)
    index=1;
else
    ERRMSG='ERROR: invalid sinusoid index';
    assert(isnumeric(index) && isscalar(index),ERRMSG);
    valid=1:object.NumberSinusoids;
    assert(any(index == valid),ERRMSG);    
end

% set frequency and update scaling
object.Parameter(index,1)=value;
scaleBasis(object);

end