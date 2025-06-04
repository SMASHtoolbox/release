function orientationResetButton(src, event, mainFigure, h_edit, ...
    h_slider, category)

obj = get(mainFigure, 'UserData');
obj = resetOrientation(obj, category);
set(mainFigure, 'UserData', obj);

updateFromEdit(mainFigure, [0 0 0], category, 'orientation', h_edit, true);
resetReference(mainFigure, h_slider, category, 'orientation');

end