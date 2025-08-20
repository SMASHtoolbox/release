%% %% make something to look at
figure;
image;

%% 
object=SMASH.ROI.Curve();
object.Name='Selection A';
object=select(object);

%%
object=add(object);
object(end).Name='Selection B';

object=manage(object);
