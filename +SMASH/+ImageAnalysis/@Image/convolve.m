% UNDER CONSTRUCTION

%
function object=convolve(object,kernel)

% verify uniform grid
object=makeGridUniform(object);

% handle input
assert(nargin<2,'ERROR: convolution kernel missing');
if ~ismatrix(kernel)
    error('ERROR: invalid smoothing kernel');
end
object.Data=conv2(object.Data,kernel,'same');
    
object=updateHistory(object);

end