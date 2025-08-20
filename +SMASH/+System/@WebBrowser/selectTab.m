% selectTab Select browser tab
%
% This method selects a particular tab in the web browser.
%    selectTab(object); % command window selection
%    selectTab(object,index);
%
% See also WebBrowser, createTab, probeTab
%

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function selectTab(object,index)

% manage input
valid=1:numel(object.Tab);
if (nargin < 2) || isempty(index)
   index=chooseIndex(object);
   if isempty(index)
       return
   end
else
    assert(any(index == valid),'ERROR: invalid tab index');
end

% simulate mouse click
report=getappdata(groot,'WebBrowser');
clickItem(object,report.Tab(index).Handle);

end