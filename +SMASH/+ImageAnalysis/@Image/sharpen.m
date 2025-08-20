% SHARPEN Sharpen method for Image objects
%
% This method sharpens the appearance of edges in a Image object by
% calculating the fractional change at each point with respect to the
% local average.  The local average is determined with smoothing over a
% specied neighborhood (11 x 11 pixels by default).  The z-limit can also
% be cropped to a specified threshold to aid visibility.
%
% Usage:
%    >> object=sharpen(object,choice,value);
%
% See also IMAGE, bin, smooth

% created 5/30/2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function object=sharpen(object,choice,value)

% handle input
assert(nargin>=3,'ERROR: sharpening choice and value are required');

temp=smooth(object,choice,value);
object=object-temp;

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);

end