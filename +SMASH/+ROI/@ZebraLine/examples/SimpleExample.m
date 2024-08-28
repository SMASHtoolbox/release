%% generate data
x=linspace(0,1,20);
y=sin(2*pi*2*x);

%% create object
hz=SMASH.Graphics.PlotTools.ZebraLine();
hz.Data=[x(:) y(:)];

%% change marker size and line width
hz.MarkerSize=10;
hz.LineWidth=0;

%% change color
hz.Color='b';
set(gca,'Color','r');

%% bring lines back
hz.LineWidth=2;