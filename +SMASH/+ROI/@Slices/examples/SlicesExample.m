%% make something to look at
figure;
image;

%% start with 'x' slices
object=SMASH.ROI.Slices('x');
object=select(object,gca);

%% manage multiple selections, make the second one 'y' slices
object(end).Name='1st selection';
object(end+1) = SMASH.ROI.Slices('y');
object(end).Name='2nd selection';
object=manage(object,'Target',gca);


%% manually define some 'x' slices as upper and lower bounds
object=add(object);
axis tight;
xb=xlim;
data=xb';
object(end)=define(object(end),data);

%% show all ROIs
view(object);
axis auto

%% clean up
 wipe(object,gca) 