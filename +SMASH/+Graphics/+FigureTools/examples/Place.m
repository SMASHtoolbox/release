%% 
list=SMASH.Graphics.DisplayTools.checkDisplay();
assert(numel(list) > 1,'ERROR: these examples require multiple monitors');

%%
close all
clear
clc

%% create two figures
for n=1:2
    figure;
end
fig=get(groot,'Children');
fig=fig(end:-1:1);

SMASH.Graphics.FigureTools.tile('vertical',[0.5 0 0.5 1],fig);
for n=1:numel(fig)
    fig(n).OuterPosition(3:4)=500;
end

%% put both figures on largest monitor
large=SMASH.Graphics.FigureTools.place();
fprintf('Placing figures on monitor #%d\n',large);

%% put both figures on smaller monitor 
small=SMASH.Graphics.FigureTools.place('smallest');
fprintf('Placing figures on monitor #%d\n',small);

%% put figure 1 back on largest monitor
SMASH.Graphics.FigureTools.place(large,fig(1));
