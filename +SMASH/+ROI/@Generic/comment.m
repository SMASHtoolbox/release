% comment Add/edit comments
%
% This method brings up interactive window for adding and editing comments
%    object=comment(object);
%

%
% created September 22, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=comment(object)

persistent FigureTools
if isempty(FigureTools)
    FigureTools=packtools.import('SMASH.Graphics.FigureTools.*');
end

list=FigureTools.focus();
FigureTools.focus('off');

default={strtrim(object.Comments)};
answer=inputdlg('Region of interest comments:','ROI comments',[10 80],default);
if isempty(answer)
    % do nothing
else
    object.Comments=answer{1};
end

FigureTools.focus(list);


end