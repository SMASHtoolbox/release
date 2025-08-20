%% make something to look at
figure;
image;

%% start with closed points
object=SMASH.ROI.Points();
object=select(object,gca);

%% convert to open points
object=convert(object,'open');
object=select(object,gca);

%% manage multiple selections
object(end).Name='1st selection';
object=copy(object);
object(end).Name='2nd selection';
object=manage(object,'Target',gca);

%% change mode
object(2)=convert(object(2),'connected');
object(2)=select(object(2),gca);

%% manually define points
object=add(object);
axis tight;
xb=xlim;
yb=ylim;
data=[xb(1) yb(1); xb(2) yb(1); xb(2) yb(2); xb(1) yb(2)];
object(end)=define(object(end),data);

%% show all ROIs
view(object);
axis auto

%% clean up
 wipe(object,gca) 