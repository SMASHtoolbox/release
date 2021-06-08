
function cmenu = FringeHandler(index, signalLabel)
% Creates a context menu for the given signal that will allow the user to
% modify fringes. FringeHandler will create a context menu that contains
% one item that is used to bring up a dialog that allows the user to modify
% the Add Fringes and the SubtractFringes.

% This is really just an object oriented wrapper around some code that
% creates a context menu, handles the context menuitem's callback by
% opening a FringeDlg then stroring the modified data back into the main
% figure's UserData, then updating the GUI.
% created 12/22/2004 by Ed Kaltenbach (ARA)

% create the context menu
cmenu = uicontextmenu('UserData', index, 'Tag', signalLabel);

% add one menuitem labeled "Edit Fringes" and set its callback
uimenu(cmenu, 'Label', 'Edit Fringes', 'Tag', 'editFringes', ...
    'Callback', @FringeMenuCallback);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function func = FringeMenuCallback(varargin)
% FRINGEMENUCALLBACK    Executed when a user selects the 'Edit Fringes' 
%                       option from the popup menu displayed after the user
%                       has right clicked on a record in the figure

VisarData = get(gcf, 'UserData');
    
% get the index of the line that was clicked
cmenu = get(gcbo, 'Parent');
index = get(cmenu, 'UserData');
    
% get number of records loaded into VisarData
s = size(VisarData);
recordCnt = s(2);
    
if index <= recordCnt
    % get the time where the user clicked and use as
    % default in the fringe dialog
    Cp = get(gca, 'CurrentPoint');
    Xp = Cp(2, 1); % X-point
    Yp = Cp(2, 2); % Y-point

    % display the fringe dialog
    VisarData = FringeDlg(VisarData, Xp, index);
        
    % VISAR analysis
    % - make sure signal is updated with new fringe data
    RecordData = VisarData{index};
    RecordData = VisarAnalysis(RecordData, 'QuadratureSignals', 'Velocity');
        
    % store the returned recordData
    VisarData{index} = RecordData;
      
    % store it back in the figure's UserData
    set(gcf, 'UserData', VisarData);
end

PointVISARGUI('update');
