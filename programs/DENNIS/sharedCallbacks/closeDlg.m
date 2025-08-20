function closeDlg(src, event, mainFigure, category, subcategory)

try
    resetReference(mainFigure, [], category, subcategory);
catch
    warning('Reference xyz data not reset properly');
end
delete(src); % not supposed to use close in callbacks

end