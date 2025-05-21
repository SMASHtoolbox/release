% probeTab Extract data from a browser tab
%
% This method extracts inforamtion from the current browser tab.
%    address=probeTab(object); % URL only
%    [address,content]=probeTab(object); % URL and all HTML content
%
% Passing a second input extracts data from a specific tab.
%    [...]=probeTab(object,index);
%
% See also WebBrowser, selectTab, updateTab
%

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function [address,content]=probeTab(object,index)

% manage input
if (nargin < 2) || isempty(index)
    index=object.CurrentIndex;
else
    valid=1:numel(object.Tab);
    assert(any(index == valid),'ERROR: invalid tab index');
end

%address=object.Tab(index).Browser.getCurrentLocation();%
address=object.Tab(index).Text.getText();
address=char(address);

if nargout >= 2
    %content=object.Tab(index).Browser.getHtmlText();
    content=webread(address);
    content=char(content);
end

end