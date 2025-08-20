%% make something to look at
figure;
image;

%% start with finite rectangle
object=SMASH.ROI.Rectangle();
object.Name='Finite bound';

object=select(object);

%% add partially finite rectangle
object=add(object,'x');
object(end).Name='Finite horizontal bound';

object=manage(object);

%% convert finite rectangle
object(1)=convert(object(1),'y');
object(1).Name='Finite vertical bound';

manage(object);