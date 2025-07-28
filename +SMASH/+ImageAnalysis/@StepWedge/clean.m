% clean Remove local artifacts
%
% This method "cleans" step wedge measurements.  Local artifacts are
% removed from a specified neighborhood via a median filter.
%     >> object=clean(object); % default neighborhood is 9x9 pixels
%     >> object=clean(object,nhood);
% Neighborhoods are specified by one or two numbers: the vertical and
% horizontal size of the neighborhood in pixels, respectively.  Specifying
% a single number sets the horizontal size to be equal to the vertical
% size.
%
% See also StepWedge, view
%

%
% created August 26, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function object=clean(object,nhood)

% manage input
if (nargin<2) || isempty(nhood)
    nhood=9;
end

% perform median filter
object.Measurement=smooth(object.Measurement,'median',nhood);    

end