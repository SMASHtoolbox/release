% SHARPEN Sharpen SignalGroup Data
%
% This method sharpens the Data array in Signal objects, removing low
% frequency content.  The methods sharpen and smooth are compliments,
% meaning that their sum is equivalent to the original object.  The general
% calling syntax is:
%    >> object=sharpen(object,choice,value);
% To learn more about the "choice" and "value" inputs, see the smooth
% method documentation.
%
% See also SignalGroup, smooth
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=sharpen(object,choice,value)

% handle input
assert(nargin>=3,'ERROR: sharpening choice and value are required');

temp=smooth(object,choice,value);
object=object-temp;

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);

end