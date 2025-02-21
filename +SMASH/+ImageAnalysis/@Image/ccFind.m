% CCFIND Find connected components 
%
% This method finds connected components useful for image filtering. With
% the exception of an added field to the output structure, this method
% mimics bwconncomp from the image processing toolbox. This method treats
% the minimum value of object.Data as false and all other values as true. 
% It probably makes sense to use only if object.Data is binary or if a
% signficant fraction of object.Data is equal to the minimum value (as is
% the case after applying removeBackground).
%
% Basic algorithm from:
% https://blogs.mathworks.com/steve/2007/03/28/neighbor-indexing/
% https://blogs.mathworks.com/steve/2007/03/20/connected-component-labeling-part-3/
%
% bwconncomp info: 
% https://www.mathworks.com/help/images/ref/bwconncomp.html
%
% Usage:
%   >> cc = ccFind(object)
%     -> find connected components with default connectivity of 8 
%   >> cc = ccFind(object, 4)
%     -> find connected components with connectivity of 4
% 
%
% See also IMAGE CCFILTER REMOVEBACKGROUND

% created October, 2022 by Nathan Brown (Sandia National Laboratories)
%
function cc=ccFind(obj, varargin)

% handle input 

if nargin > 1 && isnumeric(varargin{1}) && varargin{1} == 4
    conn = 4;
else
    conn = 8;
end

% binarize, using min as zero and everything else as nonzero

bin = obj.Data ~= min(min(obj.Data));

% find neighbor pairs in padded array (padded array necessary b/c the
% algorithm requires the edges not be part of connected components

[iiMax, jjMax] = size(bin);
indPad = [false(iiMax+2,1), [false(1,jjMax); bin; false(1,jjMax)], ...
    false(iiMax+2,1)];
offsets = [-1 iiMax+2 1 -iiMax-2]; % [n e s w]
if conn == 8
    offsets = [offsets, iiMax+1, iiMax+3, -iiMax-1, -iiMax-3]; % [ne se sw nw]
end
idx = find(indPad);
pairCell = cell(size(offsets));
for ii = 1:length(offsets)
    dIdx = idx + offsets(ii);
    dNeigh = indPad(dIdx);
    pairCell{ii} = [idx(dNeigh), dIdx(dNeigh)];
end
pairInd = vertcat(pairCell{:});

% convert padded array pair indices back to original array indices
% ind = padInd - (extraColumn + extraRow + 2*(padColumn - 2))

pairInd = pairInd - (2+iiMax + 1 + 2*(ceil(pairInd/(iiMax+2)) - 2));

% assign contiguous labels to enable connected component finding with
% dmperm

un = unique(pairInd);
labels = 1:length(un);
[a,b] = ismember(pairInd, un);
pairInd(a) = labels(b(a));

% find the connected components and convert the labels back to actual
% indices

A = sparse(pairInd(:,1), pairInd(:,2), 1);
A = A + speye(size(A));
[p, ~, r] = dmperm(A);
NumPixels = diff(r);
NumObjects = length(NumPixels);
PixelIdxList = cell(1, NumObjects);
for ii = 1:NumObjects
    ind = p(r(ii):r(ii+1)-1);
    PixelIdxList{ii} = un(ind);
end

% output results in a way that matches bwconncomp (but with an added field to
% make life easier)

cc.Connectivity = conn;
cc.ImageSize = [iiMax jjMax];
cc.NumObjects = NumObjects;
cc.PixelIdxList = PixelIdxList;
cc.NumPixels = NumPixels;


end