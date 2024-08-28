%% create three figures
close all
clear
clc

for n=1:3
    figure;
end
fig=get(groot,'Children');
fig=fig(end:-1:1);

SMASH.Graphics.FigureTools.tile('vertical',[0.5 0.25 0.5 0.75],fig);


%% figures 2-3 follow figure 1
SMASH.Graphics.FigureTools.follow(fig);

%% figure 2 follows figure 1, figure 3 does not
SMASH.Graphics.FigureTools.follow(fig(1:2));

%% disable follow
SMASH.Graphics.FigureTools.follow('off');

%% resume follow
SMASH.Graphics.FigureTools.follow('on');