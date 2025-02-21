% setLineData Set line data
%
% This method sets data for the line passing through all symbol points. 
%    setLineData(object,data);
% The input "data" is a two-column array [x y] of points. Often these
% points are more finely meshed than symbols to capture curvature, but
% various alternatives are supported.  Empty values:
%    setLineData(object,[]);
% hide the connecting line.  Symbol points can be requested:
%    setLineData(object,'symbol');
% to show straight line connections between symbols.
%
% Line style and thickness options may be passed as name-value pairs.
%    setLineData(object,data,name,value,...);
% A placeholder argument:
%    setLineData(object,'existing',name,value,...);
% allows options to be specified using existing line data.
%
% NOTE: this method does not enforce the connecting line to pass through
% any or all symbol points.  It assumed that the end user knows what they
% are doing.
%
% See also SymbolPlot, setSymbolData
%
function setLineData(object,data,varargin)

% manage input
assert(nargin > 1,'ERROR: no data array specified');
if strcmpi(data,'existing')
    data=object.LineData;
elseif strcmpi(data,'symbol')
    data=object.SymbolData;
end
    
if isempty(data)
    set(object.Line,'Visible','off','XData',[],'YData',[]);
    return
end

assert(isnumeric(data) && ismatrix(data),'ERROR: invalid data array');
[rows,cols]=size(data);
switch cols
    case 1
        x=transpose(1:rows);
        data=[x data];
    case 2
        % keep going
    otherwise
        warning('Ignoring data past the second column');       
end
object.LineData=data(:,1:2);

set(object.Line,'XData',data(:,1),'YData',data(:,2));
if nargin > 2
    try
        set(object.Line,varargin{:});
    catch ME
        throwAsCaller(ME);
    end
end
set(object.Line,'Color',object.Color,'Visible','on');

end