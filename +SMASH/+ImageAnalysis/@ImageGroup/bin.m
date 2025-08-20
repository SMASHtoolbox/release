% BIN Reduce ImageGroup resolution by binning
%
% The same binning is performed on each Image within the ImageGroup.
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
% See also ImageGroup, smooth
%

% created February 11, 2016 by Sean Grant (Sandia National Laboratories/UT)

function varargout=bin(object,binsize)

temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    tempObj{n}=bin(temp{n},binsize);
end

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});

% handle outputs
if nargout==0
    view(object);
end

if nargout>0    
    varargout = object;
end

end

