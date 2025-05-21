%% printed report
commandwindow
SMASH.Graphics.DisplayTools.checkDisplay()

%%
[list,spawn]=SMASH.Graphics.DisplayTools.checkDisplay();
for n=1:numel(list)
    fprintf('Monitor %d:\n',n);
    disp(list(n));
end
fprintf('spawn = %d\n',spawn);