% setSymbolData Set symbol data
%
% This method sets the data points where symbols are located.  
%    setSymbolData(object,data);
% The input data is a two-column array [x y] of points.
%
% See also SymbolPlot, setLineData
%
function setSymbolData(object,data)

assert(~isempty(data) && isnumeric(data) && ismatrix(data),...
    'ERROR: invalid data array');
[rows,cols]=size(data);
switch cols   
    case 1
        x=transpose(1:rows);
        data=[x data];
    case 2
        % keep going
    otherwise
        warning('Ignoring data past the second column');
        data=data(:,1:2);
end

object.SymbolData=data;
xb=[min(data(:,1)) max(data(:,1))];
yb=[min(data(:,2)) max(data(:,2))];

% update symbols
old=numel(object.Points);
if old < rows
    for n=(old+1):rows
        object.Points(n)=text('Parent',object.Parent,'Visible','off',...
            'HorizontalAlignment','center','VerticalAlignment','middle');
    end
elseif old > rows
    delete(object.Points(rows+1:end));
end

object.Points=object.Points(:);

for n=1:rows
    set(object.Points(n),'Position',data(n,:));
end
applySymbol(object);

if diff(xb) > 0
    xlim(object.Parent,xb);
end

if diff(yb) > 0
    ylim(object.Parent,yb);
end

end