% HISTOGRAM Histogram of Image data 
%
% This method performs the histogram method on one of the Images within an
% ImageGroup.
%
% This method provide a graphical representation of the distribution of 
% Image data. Elements in data are sorted into 'nbins' of equally spaced 
% bins along the x-axis between the minimum and maximum values of data.
%
% Usage:
%   >> varargout=histogram(object,ImageNumber,varargin);
% For example, histogram with 100 bins:
%   >> result = histogram(object,ImageNumber,100);
% where "result" is a Signal object, which has its own set of
% processing and visualization methods. The output variables are 
% 'nelements', the number of elements in each bin, and 'xcenters', 
% the centers of each bin.  A default of 10 bins is used,
% but may be changed by input a value for 'nbins'.
% Specifying no output variables create histogram plot of object data:
%   >> histogram(object,ImageNumber,varargin);
%
% see also ImageGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

function varargout=histogram(object,imageNumber,varargin)

% handle input
if isempty(imageNumber)||nargin<2
    sprintf('Defaulting to Image #1 for selection')
    imageNumber=1;
end
assert(rem(imageNumber,1)==0,'Frame slection must be an integer')

% split up ImageGroup
temp=cell(object.NumberImages,1);
[temp{:}]=split(object);

if nargout>0
    varargout{:}=histogram(temp{imageNumber},varargin{:});
end

if nargout==0
    histogram(temp{imageNumber},varargin{:});
end


end

