% BIN Reduce Image resolution by binning
%
% Binning is a form of smoothing, where local groups of M x N pixels are
% collected into a set of "superpixels" formed by summation over the
% original image.  The binned object spans the same grid range, reducing
% storage requirements and noise at the expense of resolution.  
%
% Usage: 
%   >> object=bin(object,[M N]); % bin object into M x N superpixels
% The binnning superpixel is determined by the second input: M is the
% Grid2 size and N is the Grid1 size.  When only one number is given: 
%   >> object=bin(object,M); % bin object into M x M superpixels
% the superpixel is assumed to be square.
%
% Calling this method with no output casues the binned result to be
% displayed without returned a new object.
%   >> bin(object,[M N]);
%
% See also Image, smooth
%

% created November 9, 2012 by Daniel Dolan (Sandia National Laboratories)
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function varargout=bin(object,binsize)

% verify uniform grid
object=makeGridUniform(object);

% handle input
if (nargin<2) || isempty(binsize)
    error('ERROR: no bin size specified');
elseif numel(binsize)==1
    binsize=repmat(binsize,[1 2]);  
end
binsize=binsize(1:2);

% use convolution to add/average neighboring pixels
kernel=ones(binsize);
z=conv2(object.Data,kernel,'valid');
[M,N]=size(z);

kernel=ones(binsize(1),1);
kernel=kernel/sum(kernel(:));
y=object.Grid2(:);
y=conv2(y,kernel,'valid');

kernel=ones(1,binsize(2));
kernel=kernel/sum(kernel(:));
x=object.Grid1;
x=reshape(x,[1 numel(x)]);
x=conv2(x,kernel,'valid');

% omit excess pixels
L=binsize(1);
if rem(L,2)==1
    m=((L+1)/2):L:M;
    ybin=y(m);
else
    m=(L/2):L:M;
    ybin=(y(m)+y(m+1))/2;
end
zbin=z(m,:);

L=binsize(2);
if rem(L,2)==1
    n=((L+1)/2):L:N;
    xbin=x(n);
else
    n=(L/2):L:N;
    xbin=(x(n)+x(n+1))/2;
end
zbin=zbin(:,n);

object=updateHistory(object);

% handle output
if nargout==0
    figure;
    imagesc(xbin,ybin,zbin);
    colormap(object.ColorMap);
    xlabel(object.Grid1Label);
    ylabel(object.Grid2Label);
    colorbar
    temp=sprintf('Binned image of ''%s''',object.GraphicOptions.Title);
    title(temp)
end

if nargout>=1
    object.Grid1=xbin;
    object.Grid2=ybin;
    object.Data=zbin;
    varargout{1}=object;
end

object=updateHistory(object);

end