% bin Reduce resolution by binning
%
% Signal binning maps data from the existing grid to a coarser grid, a
% process also known as decimation. 
%    result=bin(object,M);
% The output "result" spans the same grid range at reduced resolution and
% with less memory.  The input "M" is a positive integer control bin
% size, e.g. M=3 combines data from three grid points to one grid point.
%
% Calling this method with no output casues the binned result to be
% displayed without returned a new object.
%   >> bin(object,M);
%
% See also Signal, smooth
%

% created April 9, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=bin(object,binsize)

% manage input
assert(nargin > 1,'ERROR: no bin size specified');
assert(SMASH.General.testNumber(binsize,'integer','positive','notzero'),...
    'ERROR: invalid bin size');

% verify uniform grid
object=makeGridUniform(object);

% use convolution to add/average neighboring pixels
kernel=ones(binsize,1);
kernel=kernel/sum(kernel);
z=conv2(object.Data,kernel,'valid');
M=size(z);

x=object.Grid(:);
x=conv2(x,kernel,'valid');

% omit excess pixels
if rem(binsize,2)==1
    m=((binsize+1)/2):binsize:M;
    xbin=x(m);
else
    m=(binsize/2):binsize:M;
    xbin=(x(m)+x(m+1))/2;
end
zbin=z(m,:);

% handle output
object=reset(object,xbin,zbin);

if nargout==0
    view(object);
else
    varargout{1}=object;
end

end