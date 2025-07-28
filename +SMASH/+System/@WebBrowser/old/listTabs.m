% UNDER CONSTRUCTION

% WebBrowser.listTabs() % prints report to the command window

% tab=WebBrowser.listTabs(); % "tab" is a structure array
%
% [tab,browser]=WebBrowser.listTabs();

function varargout=listTabs()

master=getMaster();
report=[];

list=matchClass(master,'Tabs\$Tab');
for n=1:numel(list)
    temp=char(list{n}.getText);
    if isempty(temp)
        continue
    end
    tab.Name=temp;
    temp=list{n}.getLocation();   
    tab.Position=temp.getX();
    if isempty(report)
        report=tab;
    else
        report(end+1)=tab; %#ok<AGROW>
    end
end
report=report(end:-1:1);

if nargout == 0    
    N=numel(report);
    format=sprintf('Tab %%%dd : %%s\\n',floor(log10(N)));
    for n=1:N
        fprintf(format,n,report(n).Name);
    end
else
    varargout{1}=report;
end

end