% closeTab Close browser tab
%
% This method closes a web browser tab.
%    closeTab(object); % close current tab
%    closeTab(object,index); % close specified tab
%
% See also WebBrowser, createTab
%

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function closeTab(object,index)

% manage input
if (nargin < 2) || isempty(index)
    index=object.CurrentIndex;
else
    valid=1:numel(object.Tab);
    assert(any(index == valid),'ERROR: invalid tab index');
end

try
    report=getappdata(groot,'WebBrowser');
    h=matchClass(report.Tab(index).Handle,'CloseButton');
    clickItem(object,h{1});
catch
    error('ERROR: invalid tab specified');
end


end