function resetReference(mainFigure, h_slider, category, subcategory)

obj = get(mainFigure, 'UserData');

if ischar(subcategory)
    subcategory = {subcategory};
end

for ii = 1:length(subcategory) 
    subcategoryRef = [subcategory{ii}, 'Reference'];
    obj = changeObject(obj, category, subcategoryRef, ...
        obj.(category).(subcategory{ii}));
end

set(mainFigure, 'UserData', obj);

if ~isempty(h_slider) && isvalid(h_slider(2))
    set(h_slider(2), 'Value', 0);
end

end