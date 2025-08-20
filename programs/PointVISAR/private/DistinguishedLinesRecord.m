function color=DistinguishedLinesRecord(number)

%Pre-2014b Matlab defaults
map=[];
map(end+1,:)=[0.00 0.00 1.00]; % blue
map(end+1,:)=[0.00 0.50 0.00]; % green
map(end+1,:)=[1.00 0.00 0.00]; % red
map(end+1,:)=[0.00 0.75 0.75]; % cyan
map(end+1,:)=[0.75 0.00 0.75]; % magenta
map(end+1,:)=[0.75 0.75 0.00]; % yellowish
map(end+1,:)=[0.25 0.25 0.25]; % grey

Ncolor=size(map,1);
while number>Ncolor
    number=number-Ncolor;
end
color=map(number,:);