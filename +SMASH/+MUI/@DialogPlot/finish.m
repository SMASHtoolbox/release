% finish Finish dialog plot
%
% This method finalizes the controls in a dilaog plot.
%    finish(object)
% The "addblock" method will *not* work after the object has been
% finalized.
%
% See also DialogPlot, addblock
%

%
% created April 2, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=finish(object)

object.Locked=true;
delete(object.DialogBox);

end