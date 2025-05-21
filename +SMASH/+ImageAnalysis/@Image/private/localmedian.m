% This function applies local median filtering on 2D arrays.
%    >> new=localmedian(array,nhood);
% The default neighborhood is 3x3.  Larger neighborhoods may be specified
% by passing a "nhood" input.
% 
% Median filtering is always slower than convolution operations (mean, etc)
% and is not linear, so it should be used catiously.  This implementation
% of the median filter does not require the Image Processinng toolbox and
% is about 3x slower than medfilt2.  No padding options are currently
% supported: any neighborhood point outside of the input image
% automatically mirrors the center point
%

% created December 6, 2013 by Daniel Dolan (Sandia National Laboratories)
function new=localmedian(array,nhood)

% handle input
if (nargin<2) || isempty(nhood)
    nhood=3;
    
end
assert(isnumeric(nhood),'ERROR: invalid neigbborhood');
if isscalar(nhood)
    nhood=repmat(nhood,[1 2]);
end
assert(numel(nhood)==2,'ERROR: invalid neigbborhood');
assert(all((nhood>0) & (nhood==round(nhood))),...
    'ERROR: invalid neigbborhood');

% create offset array
[N,M]=size(array);

offset1=1:nhood(1);
if rem(nhood(1),2)==1
    offset1=offset1-(nhood(1)+1)/2;
else
    offset1=offset1-nhood(1)/2;
end
offset1=repmat(offset1(:),1,nhood(2));

offset2=1:nhood(2);
if rem(nhood(2),2)==1
    offset2=offset2-(nhood(2)+1)/2;
else
    offset2=offset2-nhood(1)/2;
end
offset2=repmat(N*offset2,nhood(1),1);

offset=offset1+offset2;
offset=reshape(offset,1,[]);
offset=repmat(offset,N,1);

% sweep through array in vertical strips
new=nan(N,M);
strip=1:N;
strip=repmat(strip(:),1,size(offset,2));
lower=1;
upper=numel(array);
for m=1:M
    % construct local array
    local=strip+offset;
    replace=(local<lower) | (local>upper);
    local(replace)=strip(replace); % replace invalid values with center value
    local=array(local);
    % calculate median
    new(:,m)=median(local,2);
    % prepart for next iteration
    strip=strip+N;    
end

end