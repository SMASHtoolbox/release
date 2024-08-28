%% manually specify font size
SMASH.MUI.setFonts('FontSize',20,'FontWeight','bold');
figure; axes

%% store/restore settings
previous=SMASH.MUI.setFonts();
SMASH.MUI.setFonts('FontSize',10,'FontWeight','normal',...
    'FontAngle','italic');
figure; axes

SMASH.MUI.setFonts(previous);
figure; axes

%% specify number of text rows
SMASH.MUI.setFonts('rows',50);
figure; axes

%% restore factory defaults
SMASH.MUI.setFonts('factory');
figure; axes