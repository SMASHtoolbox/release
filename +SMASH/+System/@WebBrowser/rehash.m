% rehash Scan browser contents
%
% This method scans MATLAB's web browser, looking for changes that may have
% occured outside of the WebBrowser object's control
%    rehash(object);
%
% See also WebBrowser
%

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function rehash(object)

[~,browser]=web();
stall=false;
while true
    try
        report.Master=browser.getRootPane().getParent();
    catch
        if stall
            fprintf('.');
        else
            fprintf('Waiting for browser response ');
            stall=true;
        end
        pause(0.5);
        continue
    end
    break
end
fprintf('done\n');
setappdata(groot,'WebBrowser',report);

% generate report
report.Tab=[];
L2=[];
htab=matchClass(report.Master,'Tabs\$Tab');
htext=matchClass(report.Master,'TextField');
MissingTab=0;
for n=1:numel(htab)
    temp=char(htab{n}.getText);
    if isempty(temp)
        continue
    end
    tab.Name=temp;
    if htab{n}.isVisible
        clickItem(object,htab{n});
        pause(0.2);
        [~,tab.Browser]=web();
        tab.Handle=htab{n};
        for m=1:numel(htext)
            if htext{m}.isShowing
                tab.Text=htext{m};
            end
        end
    else
        MissingTab=MissingTab+1;
        continue                
    end    
    %
    if isempty(report.Tab)
        report.Tab=tab;
    else
        report.Tab(end+1)=tab;
    end
    x0=htab{n}.getLocation().getX();
    y0=htab{n}.getLocation().getY();
    L2(end+1)=hypot(x0,y0); %#ok<AGROW>    
end
[~,index]=sort(L2);
report.Tab=report.Tab(index);

setappdata(groot,'WebBrowser',report);
selectTab(object,numel(object.Tab));

if MissingTab > 0
    message{1}=sprintf('Browser has %d invisible tab(s).  To make these tabs visible,',MissingTab);
    message{2}=sprintf('increase the window size or change the tab orientation');
    warning('%s\n',message{:});
end

end