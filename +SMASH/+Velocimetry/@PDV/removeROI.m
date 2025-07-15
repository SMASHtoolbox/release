% removeROI Remove regions of interest
%
%
% created February 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=removeROI(object)

object.ROIselection=[];
object=changeStatus(object,'obsolete','History');
object=changeStatus(object,'incomplete','ROI');

end