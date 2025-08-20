% apply Apply symbols to plot
%
% This method applies all defined symbols to the symbol plot.
%    applySymbol(object);
% Symbols are reused as necessary to span plot points.
%
% See also SymbolPlot, addSymbol, removeSymbol, showSymbol
%
function applySymbol(object)

group=object.Points;
n=1;
N=numel(object.Symbol);
for k=1:numel(group)
    symbol=object.Symbol(n);
    set(group(k),'FontName',symbol.Name,'String',symbol.Character,...
        'FontSize',symbol.Size,'Interpreter','none','Visible','on');
    if n < N
        n=n+1;
    else
        n=1;
    end
end


end