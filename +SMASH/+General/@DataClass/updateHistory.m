% updateHistory Append calling function to the ObjectHistory list
%
% Usage:
%    >> object=updateHistory(object);
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=updateHistory(object)

callstack=dbstack('-completenames');
object.ObjectHistory{end+1}=callstack(2).name;

end