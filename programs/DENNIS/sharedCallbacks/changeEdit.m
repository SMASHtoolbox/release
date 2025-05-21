function changeEdit(src, event, mainFigure, h_edit, h_slider, ...
    category, subcategory, varargin)

if nargin == 2 + 6
    optFlag = true;
    extraOption = get(varargin{1}, 'Value');
else
    optFlag = false;
end

new = editExtract(h_edit);
if optFlag
    updateFromEdit(mainFigure, new, category, subcategory, h_edit, true, ...
        extraOption);
    if extraOption && strcmpi(category, 'source') && strcmpi(subcategory, 'rotate')
       [db, ex] = createDlg(mainFigure, 'detectorDlg', 'dialog', false);
       if ex
           close(db.Handle);
       end
   end
else
    updateFromEdit(mainFigure, new, category, subcategory, h_edit, true);
end

if any(ishandle(h_slider)) % updated in MATLAB 2024b b/c h_slider(1) stopped being a handle
    resetReference(mainFigure, h_slider, category, subcategory);
end

if nargin == 2 + 8
    resetHandle = varargin{1};
    resetType = varargin{2};
    resetValue = varargin{3};
    for ii = 1:length(resetHandle)
        set(resetHandle{ii}, resetType{ii}, resetValue{ii});
    end
end

end