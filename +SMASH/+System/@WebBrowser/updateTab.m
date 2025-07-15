% updateTab Update browser tab
%
% This method updates the current browser tab.
%    updateTab(object,address);
% If no address is specified, the current location is reloaded.
%
% Passing a third input updates a specific browser tab.
%    updateTab(object,address,index)
%
% See also WebBrowser, createTab, probeTab
% 

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function updateTab(object,address,index)

[~,~,url]=web();
assert(~isempty(url),'ERROR: this tab cannot be updated');

% manage input
if (nargin < 2) || isempty(address)
    address=url;
end

valid=1:numel(object.Tab);
if (nargin < 3) || isempty(index)                
    index=object.CurrentIndex;
else     
    assert(any(index == valid),'ERROR: invalid tab index');
end

% update tab
selectTab(object,index);
web(address);

end