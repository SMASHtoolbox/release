function value=getCursorLocation()

units=get(groot,'Units');
set(groot,'Units','pixels');
value=get(groot,'PointerLocation');

if strcmpi(units,'pixels')
    return
end
set(groot,'Units',units);

end