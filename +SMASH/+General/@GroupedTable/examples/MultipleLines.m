%% generate ideal data
slope=[1 2 3];
time=linspace(0,1,5);
[slope,time]=meshgrid(slope,time);
data=slope.*time;

data=[time(:) slope(:) data(:)];
plot(data(:,1),data(:,3));
figure(gcf);

%% mess things up a bit
data(:,2)=data(:,2)+0.01*randn(size(data(:,2)));
index=randperm(size(data,1));
data=data(index,:);

plot(data(:,1),data(:,3)); % distinct trends are not obvious
figure(gcf);

%% create grouped table
object=SMASH.General.GroupedTable(data);
object=group(object,2,0.5);

view(object,1,3); % distinct trends are obvious