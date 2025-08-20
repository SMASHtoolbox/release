% removeSymbol Remove existing symbol
%
% This method removes one or more symbols for plotting.
%    removeSymbol(object,index);
% The input "index" can be a specific integer or array of integers.
% Omitting the input or specifying 'all':
%    removeSymbol(object,'all');
% removes all existing symbols.  Removing all symbols takes the object back
% to its default state, which has one default symbol ('x').
%
% NOTE: plots are not updated until the applySymbol method is called.
%
% See also SymbolPlot, addSymbol, applySymbol, showSymbol
%
function removeSymbol(object,index)

% manage input
N=numel(object.Symbol);
valid=1:N;
if (nargin < 2) || strcmpi(index,'all')
    index=valid;
else
    ERRMSG='ERROR: invalid symbol index';
    assert(isnumeric(index),ERRMSG);
    valid=1:N;
    for n=1:numel(index)
        assert(any(index(n) == valid),ERRMSG);
    end
end

keep=true(N,1);
keep(index)=false;
object.Symbol=object.Symbol(keep);

if isempty(object.Symbol)
    entry='x';
    value=double(entry);
    name=get(groot(),'FixedWidthFontName');
    object.Symbol=struct('Character',entry,'Value',value,...
        'Name',name,'Size',12);
end