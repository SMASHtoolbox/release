%% create separate axes
figure;

haxes(1)=subplot(2,1,1);
image;
xlabel('xA');
ylabel('yA');

haxes(2)=subplot(2,1,2);
line([1 100],[1 100],'Color','k','LineWidth',2);
xlabel('xB');
ylabel('yB');

%% basic overlay
new=SMASH.Graphics.AxesTools.overlay(haxes);

%% link horizontal axes
new=SMASH.Graphics.AxesTools.overlay(haxes,'x');

%% link vertical axes
new=SMASH.Graphics.AxesTools.overlay(haxes,'y');

%% link both axes
new=SMASH.Graphics.AxesTools.overlay(haxes,'xy');