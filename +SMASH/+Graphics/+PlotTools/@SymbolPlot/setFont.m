% setFont Set symbol font
%
% The method controls the font used for new symbol addition;
% existing symbols are *not* affected.  Fonts can be specified explicitly:
%    setFont(object,value);
% where "value" is valid system font.  Empty or omitted values invoke
% interactive font selection.
%
% The command:
%    setFont(object,'default');
% selects the default fixed width font.
% 
% See also SymbolPlot, listfonts

function setFont(object,value)

% manage input
if (nargin < 2) || isempty(value)
    value=uisetfont();
    if isnumeric(value)
        return
    end
    value=value.FontName;
elseif strcmpi(value,'default')
    value=get(groot,'FixedWidthFontName');
    list=listfonts();
    assert(any(strcmpi(value,list)),'ERROR: unknown symbol font');
end

object.SymbolFont=value;

end