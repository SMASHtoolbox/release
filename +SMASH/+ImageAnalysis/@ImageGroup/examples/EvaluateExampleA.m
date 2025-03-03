%% generate a random image group
object=SMASH.ImageAnalysis.ImageGroup([],[],randn(100,100,20));
%view(object);

%% calculate mean and standard deviation images
new=evaluate(object,@(q) mean(q,3),@(q) std(q,[],3));
view(new);
