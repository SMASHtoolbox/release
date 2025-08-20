% repair Regenerate deleted graphics
%
% This method regenerates deleted graphics associated with a symbol plot.
%    repair(object);
% Users should call this method to restore accidently deleted symbols or
% connection lines.  It can also regenerate the complete plot if the original
% parent axes/figure is deleted.
%
% See also SymbolPlot
%
function repair(object)

if ~ishandle(object.Parent)
    figure();
    object.Parent=gca();
end

if ~any(ishandle(object.Points))
   try %#ok<TRYNC>
       delete(object.Points);
   end
   object.Points=[];
end
try %#ok<TRYNC>
    setSymbolData(object,object.SymbolData);
end

if isempty(object.Line) || ~ishandle(object.Line)
    object.Line=line('Parent',object.Parent,'Visible','off',...
        'XData',[],'YData',[]);    
end
try %#ok<TRYNC>
    setLineData(object,'existing');
end

end