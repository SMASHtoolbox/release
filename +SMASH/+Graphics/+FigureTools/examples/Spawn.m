%% 
list=SMASH.Graphics.DisplayTools.checkDisplay();
assert(numel(list) > 1,'ERROR: these examples require multiple monitors');

%%
close all
clear
clc

%% create figures on monitor 1
SMASH.Graphics.FigureTools.spawn(1);
SMASH.Graphics.FigureTools.spawn(1,'northeast');

%% create figures on monitor 2
SMASH.Graphics.FigureTools.spawn(2);
SMASH.Graphics.FigureTools.spawn(2,'southwest');

%% create figures on largest and smallest monitors
SMASH.Graphics.FigureTools.spawn('largest','northwest');
SMASH.Graphics.FigureTools.spawn('smallest','southeast');
