% modified from Justin Brown's function in SMASH.DynamicMaterials.DMPGUI

function [db, ex] = createDlg(src, name, type, varargin)

ex = false;
db = nan;

if isappdata(src, name)
    db = getappdata(src, name);
    if isvalid(db)
        if strcmpi(type, 'dialog')
            if ishandle(db.Handle)
                figure(db.Handle)
                ex = true;
                return
            end
        elseif strcmpi(type, 'dialogplot')
            if isvalid(db) && ~isempty(db.Axes)
                figure(db.Figure)
                ex = true;
                return
            end
        end
    end
end

if nargin < 4 || varargin{1}
    switch lower(type)
        case 'dialog'
            db = SMASH.MUI.Dialog;
        case 'dialogplot'
            db = SMASH.MUI.DialogPlot;
    end
    setappdata(src, name, db);
end

end