% reverse Reverse foreground/background colors
%
% This method reverse the background and foreground colors in an
% AlternatingLine.
%     >> reverse(object);
%
% See also AlternatingLine
%

%
% created December 10, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function reverse(object)

temp=object.ForegroundColor;
object.ForegroundColor=object.BackgroundColor;
object.BackgroundColor=temp;

end