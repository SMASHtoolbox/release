% singlePeak Single (upward) peak analysis
%
% This function analyzes a (x,y) data set assuming that a single, upward
% peak is present.
%     >> result=singlePeak(x,y,method,threshold);
% The output "result" is a 3x1 array containing the peak position, width,
% and y-value.  The "method" and "threshold" inputs are optional.
%
% The default analysis method is 'maximum', which looks for the largest
% y-value; the width is the difference between the largest and smallest
% x-value.  The 'centroid' method uses weighted integration to determine
% the center of mass, standard deviation, and average y-value.  The
% 'gaussian' method applies a Gaussian fit to determine peak position,
% width, and maximum value.
% 
% Thresholding restricts analysis to regions near the peak.  Thresholds are
% expressed as fractions of the total vertical range, e.g., 0.50 specifies
% the top 50%.  The first location that meets the threshold is used as the
% left boundary of the peak region; the last location that meets the
% threshold is the right boundary.
%
% See also CurveFit, fitGaussian
%

%
% created November 21, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function result=singlePeak(x,y,method,threshold)

% handle input
assert(nargin>=2,'ERROR: insufficient input');
assert(numel(x)==numel(y),'ERROR: incompatible (x,y) data');
x=x(:);
y=y(:);

if (nargin<3) || isempty(method)
    method='maximum';
end
assert(ischar(method),'ERROR: invalid method name');

if (nargin<4) || isempty(threshold)
    threshold=0;
end
assert(SMASH.General.testNumber(threshold,'positive'),...
    'ERROR: invalid threshold');
assert((threshold>=0) & (threshold<1),...
    'ERROR: theshold must be betwen zero and one');

% apply threshold
if ~isempty(threshold)
    ymin=min(y);
    ymax=max(y);
    threshold=ymin+(ymax-ymin)*threshold;
    keep=find(y>=threshold);
    keep=min(keep):max(keep);
    x=x(keep);
    y=y(keep);
end
assert(numel(x)>=3,...
    'ERROR: at least three points are needed for peak analysis');

% use requested analysis
result=zeros(3,1); % location, width, amplitude
switch lower(method)
    case 'maximum' 
        [ypeak,index]=max(y);
        result(1)=x(index);
        result(2)=(max(x)-min(x))/2;
        result(3)=ypeak;
    case 'centroid'
        weight=y/trapz(x,y);
        result(1)=trapz(x,weight.*x);
        result(2)=sqrt(trapz(x,weight.*(x-result(1)).^2));
        result(3)=mean(y);
    case 'gaussian'        
        param=fitGaussian(x,y);
        result(1)=param(3);
        result(2)=param(4);
        result(3)=param(2)+param(1);
    otherwise
        error('ERROR: ''%s'' is an invalid peak analysis method',method);
end

end