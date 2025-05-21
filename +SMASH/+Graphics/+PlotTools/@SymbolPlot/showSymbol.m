% showSymbol Show defined symbols
%
% This method shows all defined symbols in a new figure.
%    showSymbol(object);
%
% See also SymbolPlot, addSymbol, applySymbol, removeSymbol
%
function showSymbol(object)

N=numel(object.Symbol);
if N <= 5
    cols=N;
    rows=1;    
else
    cols=ceil(sqrt(N));
    rows=ceil(N/cols);
end

figure();
k=1;
for m=1:rows
    for n=1:cols
        label=sprintf('%d: ',k);
        text(n,m,label,'HorizontalAlignment','right');
        symbol=object.Symbol(k);
        text(n,m,symbol.Character,...
            'FontName',symbol.Name,'FontSize',symbol.Size,...
            'HorizontalAlignment','left','Interpreter','none');
     k=k+1;   
     if k > N
         break
     end
    end
end
xlim([0 cols+1]);
ylim([0 rows+1]);
set(gca,'YDir','reverse','XTick',[],'YTick',[]);
title('Defined symbols')
axis off;

end