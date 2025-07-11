% showExample Generate named examples.
%
% This *static* methods generates a named symbol plot example.
%    object=SymbolPlot.showExample(name);
% Valid names include 'basic' (default), 'fancy', and 'advanced'.  These
% examples build upon each other using the same underlying data.  The basic
% example places 'x' symbols on coarsely-sampled sinusoid.  The fancy
% example changes those symbols to yin-yang using the 'Wingdings' font.
% The advanced example adds a finely sampled line passing through those
% markers.
%
% The command:
%    object=SymbolPlot.showExample('all');
% generates all valid examples and returns and object array.
%
% See also SymbolPlot
%
function object=showExample(name)

% manage input
valid={'basic' 'fancy' 'advanced'};
if (nargin < 1) || isempty(name)
    name='basic';
elseif strcmpi(name,'all')
    for n=1:numel(valid)
        figure();
        object(n)=packtools.call('SymbolPlot.showExample',valid{n}); %#ok<AGROW>
    end
    return
else
    assert(ischar(name) || isStringScalar(name),'ERROR: invalid example name');
    name=lower(char(name));
    assert(any(strcmp(name,valid)),'ERROR: invalid example name');    
end

% common data set
x=linspace(0,2,100);
y=cospi(2*x);
xp=linspace(x(1),x(end),20);
yp=interp1(x,y,xp);
data=[xp(:) yp(:)];
object=packtools.call('SymbolPlot',data);

% specific examples
if strcmp(name,'basic')
    title('Basic symbol plot example');
    return
end

setFont(object,'wingdings')
addSymbol(object,91,20);
removeSymbol(object,1);
applySymbol(object);
if strcmp(name,'fancy')
    title('Fancy symbol plot example');
    return
end

title('Advanced symbol plot example');
setLineData(object,[x(:) y(:)]);

end