% LOCATE Locate feature in an object
%
% This method locates features in an Image object.  By default,
% the feature is assumed to be a single Gaussian peak.
%    >> report=locate(object);
% The output structure "report" contains information about the located
% feature.  If no output is specified, the peak location is plotted to a new
% figure.
% 
% Single Gaussian peak location is the only function currently supported.
%
%
% See also Image
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
% Modified January 20, 2016 by Sean Grant (Sandia National Laboratories/UT)
% 
function varargout=locate(object,curvefit,guess,bound)

% manage input
if (nargin<2) || isempty(curvefit) || strcmpi(curvefit,'peak') ...
        || strcmpi(curvefit,'gaussian')
    curve='gauss';
% elseif strcmpi(curvefit,'step')
%     curve='erf';
end

if nargin<3
    guess=[];
end

if nargin<4
    bound=[];
end

% apply curvefit
[x1,x2,y]=limit(object);
try
    switch curve
        case 'gauss'
            report=gaussfit(x1,x2,y,guess,bound);
%         case 'step'
%             report=erffit(x1,y,guess,bound);
    end
catch
    message={};
    message{end+1}='ERROR: locate failed';
    error('%s\n',message{:});
end

% handle output
if nargout==0   
    view(object);
    line(report.Location(1),report.Location(2),'Marker','o','Color','r');
    label=sprintf('Location = %#+g',report.Location);
    title(label);
else
    varargout{1}=report;
end

end