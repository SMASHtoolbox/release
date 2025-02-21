function xyzSliderRadio(src, event, mainFigure, h_radio, h_slider, ...
    category, subcategory)

set(h_radio(1:3), 'Value', 0);
str = lower(get(src,'String'));
ind = str - 'x' + 1;
if ind < 0
    ind = ind + 'x' - 'a';
end

set(h_radio(ind), 'Value', 1);

resetReference(mainFigure, h_slider, category, subcategory);

end

