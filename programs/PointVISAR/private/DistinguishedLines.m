function color=DistinguishedLines(number)

map=[];
map(end+1,:)=[0.00 0.00 1.00]; % blue
map(end+1,:)=[0.00 1.00 0.00]; % green
map(end+1,:)=[1.00 0.00 0.00]; % red
map(end+1,:)=[0.00 1.00 1.00]; % cyan
map(end+1,:)=[1.00 0.00 1.00]; % magenta
map(end+1,:)=[0.75 0.75 0.00]; % yellowish
map(end+1,:)=[0.00 1.00 0.50];
map(end+1,:)=[1.00 0.50 0.00];
map(end+1,:)=[0.50 0.00 1.00];
map(end+1,:)=[0.00 0.50 1.00];
map(end+1,:)=[0.50 1.00 0.00];
map(end+1,:)=[1.00 0.00 0.50];
map=[map; 0.75*map]; % some darker variations

Ncolor=size(map,1);
while number>Ncolor
    number=number-Ncolor;
end
color=map(number,:);