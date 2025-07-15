% createTab Create new browser tab
%
% This method creates a new tab in the web browser.
%    createTab(object); % empty tab
%    createTab(object,address); % open tab at a specified address
%
% See also WebBrowser, closeTab
%

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function createTab(object,address)

if nargin < 2
    address='';
end

try
    web(address,'-new');
catch ME
    throwAsCaller(ME)
end

rehash(object);

end