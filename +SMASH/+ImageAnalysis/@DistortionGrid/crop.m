% crop Crop step wedge measurement
%
% This method crops the measured step wedge image.  Cropping can be
% selected interactively:
%     >> object=crop(object);
%     >> object=crop(object,'manual');
% or by specifying horizontal and vertical ranges.
%     >> object=crop(object,hrange,vrange);
%
% NOTE: images should be cropped so that only the step wedge is visible.
% Failures in the analyze method are often assocaited with improper
% cropping.
%
% See also StepWedge, analyze, view
%

%
% created August 26, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function object=crop(object,varargin)

% manage input
if numel(varargin)==0
    varargin{1}='manual';
end

object.Measurement=crop(object.Measurement,varargin{:});
object.Cropped=true;

end