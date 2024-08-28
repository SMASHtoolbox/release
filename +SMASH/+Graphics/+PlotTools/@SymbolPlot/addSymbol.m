% addSymbol Add new symbol
%
% This method adds a new symbol for plotting.
%    addSymbol(object,Value,Size);
% The required input "Value" indicates either the numeric value (e.g.,
% ASCII code) associated with the symbol or its character representation.
% The optional input "Size" indicates the symbol size in points (default is
% 12).  These inputs, in conjunction with the current SymbolFont property
% value, control the appearance of the new symbol.  For example:
%    setFont(object,'wingdings');
%    addSymbol(object,91,10);
% adds a 10 point yin-yang character to the symbol list.
% 
% Character phrases can be used as symbols.  For example:
%    setFont(object,'default');
%    addSymbol(object,'here',10:2:20);
% adds six symbols with the word 'here" in progressively larger font size.
%
% Multiple integer values can be specified at the same time.  For example:
%    setFont(object,'default');
%    addSymbol(object,'here',97:122,Size);    
% indicates all lower case letters from 'a' to 'z'.  The optional input
% "Size" can be a scalar (common to each symbol) or an array consistent
% with numeric input (26 values in the above example).
%
% NOTE: plots are not updated until the applySymbol method is called.
%
% See also SymbolPlot, applySymbol, removeSymbol, showSymbol
%
function addSymbol(object,Entry,Size)

% manage input
assert(nargin >= 2,'ERROR: no symbol defined');
if isStringScalar(Entry)
    Entry=char(Entry);
end
phrase=false;
if ischar(Entry)    
    %assert(isscalar(Entry),...
    %    'ERROR: symbols must be defined one character at a time');
    if ~isscalar(Entry)
        phrase=true;
    end
    Entry=uint64(Entry);
else
    assert(isnumeric(Entry),'ERROR: invalid symbol request');
end

if (nargin < 3) || isempty(Size)
    Size=12;
else
    assert(isnumeric(Size) && all(Size > 0),'ERROR: invalid symbol size');
end

Nentry=numel(Entry);
if phrase
    Nentry=1;
end
Nsize=numel(Size);
if (Nentry == 1) && (Nsize == 1)
    new=struct('Character',char(Entry),'Value',Entry,...
        'Name',object.SymbolFont,'Size',Size);
    object.Symbol(end+1)=new;
elseif Nentry == 1
    for n=1:Nsize
        new=struct('Character',char(Entry),'Value',Entry,...
            'Name',object.SymbolFont,'Size',Size(n));
        object.Symbol(end+1)=new;
    end
elseif Nsize == 1
    for n=1:Nentry
        new=struct('Character',char(Entry(n)),'Value',Entry(n),...
            'Name',object.SymbolFont,'Size',Size);
        object.Symbol(end+1)=new;
    end
else
    assert(Nentry == Nsize,'ERROR: inconsistent number of symbol values/sizes');
    for n=1:Nentry
        new=struct('Character',char(Entry(n)),'Value',Entry(n),...
            'Name',object.SymbolFont,'Size',Size(n));
        object.Symbol(end+1)=new;
    end
end


end