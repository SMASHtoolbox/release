function setProgramFont()

%SMASH.MUI.setFonts('rows',100);
switch lower(computer)
    case 'maci64'
        SMASH.MUI.setFonts('FontUnits','points','FontSize',16);
    case 'win64'
        SMASH.MUI.setFonts('FontUnits','points','FontSize',12);
    otherwise
        % do nothing
end

end