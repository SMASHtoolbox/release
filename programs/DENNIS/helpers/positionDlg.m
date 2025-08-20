function positionDlg(db, mainFigure)

% make absolutely sure these two are on the same units scheme

set(db.Handle, 'Units', 'Pixels');
set(mainFigure, 'Units', 'Pixels');

% move the dlg

movegui(db.Handle, 'center');
mainFigurePos = get(mainFigure, 'position');
dlgPos = get(db.Handle, 'position');
dlgPos(1) = mainFigurePos(1);
set(db.Handle, 'position', dlgPos);

end