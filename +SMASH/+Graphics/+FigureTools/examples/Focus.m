%% create three figures
close all
clear
clc

for n=1:3
    figure;
end
fig=get(groot,'Children');
fig=fig(end:-1:1);

SMASH.Graphics.FigureTools.tile('vertical',[0.5 0 0.5 1],fig);

%% focus on the first two figures
SMASH.Graphics.FigureTools.focus(fig(1:2));
allowed=SMASH.Graphics.FigureTools.focus();

figure(3);

%% disable focus
SMASH.Graphics.FigureTools.focus('off');
figure(3);

%% resume focus
SMASH.Graphics.FigureTools.focus('on');
figure(3);
