% LOCATE Locate feature in an object
%
% This method locates features in one Image of an ImageGroup object.  
% By default, the feature is assumed to be a single Gaussian peak.
%    >> report=locate(object);
% The output structure "report" contains information about the located
% feature.  If no output is specified, the peak location is plotted to a new
% figure.
% 
% Single Gaussian peak location is the only function currently supported.
%
% see also ImageGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

function varargout=locate(object,imageNumber,curvefit,guess,bound)

% handle input
if  nargin<2 || isempty(imageNumber)
    sprintf('Defaulting to Image #1 for selection')
    imageNumber=1;
end
assert(rem(imageNumber,1)==0,'Image selection must be an integer')

if nargin<3
    curvefit=[];
end
if nargin<4
    guess=[];
end
if nargin<5
    bound=[];
end

% split up ImageGroup
temp=cell(object.NumberImages,1);
[temp{:}]=split(object);

if nargout>0
    varargout=locate(temp{imageNumber},curvefit,guess,bound);
end

if nargout==0
    locate(temp{imageNumber},curvefit,guess,bound);
end


end

