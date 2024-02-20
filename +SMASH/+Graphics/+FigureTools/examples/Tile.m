%% create three figures
close all
clear
clc

for n=1:3
    figure;
end
fig=get(groot,'Children');
fig=fig(end:-1:1);

%% horizontal array on full monitor
SMASH.Graphics.FigureTools.tile();

%% % 2 x 2 array on full monitor
SMASH.Graphics.FigureTools.tile([2 2]); 

%% vertical array on right side of monitor
SMASH.Graphics.FigureTools.tile('vertical',[0.5 0 0.5 1]);

%% two-column array on the right side of monitor
SMASH.Graphics.FigureTools.tile([inf 2],[0.5 0 0.5 1]);