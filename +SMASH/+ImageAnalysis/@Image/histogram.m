% HISTOGRAM Histogram of Image data 
%
% This method provide a graphical representation of the distribution of 
% Image data. Elements in data are sorted into 'nbins' of equally spaced 
% bins along the x-axis between the minimum and maximum values of data.
%
% Usage:
%   >> varargout=histogram(object,varargin);
% For example, histogram with 100 bins:
%   >> result = histogram(object,100);
% where "result" is a Signal object, which has its own set of
% processing and visualization methods. The output variables are 
% 'nelements', the number of elements in each bin, and 'xcenters', 
% the centers of each bin.  A default of 10 bins is used,
% but may be changed by input a value for 'nbins'.
% Specifying no output variables create histogram plot of object data:
%   >> histogram(object,varargin);
% 
%
% See also IMAGE

% created December 17, 2014 by Tommy Ao (Sandia National Laboratories)
% modified January 14, 2014 by Tommy Ao 

%
function varargout=histogram(object,varargin)

varargout=cell(1,nargout);
% extract data from limited region
[~,~,data]=limit(object);

[nelements,xcenters]=hist(data(:),varargin{:});

% create Signal object to hold the results
result=SMASH.SignalAnalysis.Signal(xcenters,nelements);
result.Name=object.Name;
result.GraphicOptions.Title=object.GraphicOptions.Title;
result.GridLabel='Bin centers';
result.DataLabel='Number of elements';
result.Source='Image operation';

% handle output
if nargout==0
        view(result);
elseif nargout==1
    varargout{1}=result;
else
    error('ERROR: Invalid number of outputs');
end

end