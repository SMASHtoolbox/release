function report=PFFreport(dataset,choice)

N=numel(dataset);

% determine maximum widths
NumberWidth=log10(N);
temp=ceil(NumberWidth);
if NumberWidth==temp
    NumberWidth=temp+1;
else
    NumberWidth=temp;
end

TypeWidth=0;
LabelWidth=0;
TitleWidth=0;
for n=1:N
    temp=numel(dataset(n).Type);
    TypeWidth=max([TypeWidth temp]);
    temp=numel(dataset(n).TypeLabel);
    LabelWidth=max([LabelWidth temp]);
    temp=numel(dataset(n).Title);
    TitleWidth=max([TitleWidth temp]);
end

% create report
report=cell(1,N);
switch lower(choice)
    case 'debug'
        format=sprintf('%%%dd: %%%ds %%-%ds %%-%ds',...
            NumberWidth,TypeWidth,LabelWidth,TitleWidth);
    otherwise
        format=sprintf('%%%dd: %%-%ds %%-%ds',...
            NumberWidth,LabelWidth,TitleWidth);
end

for n=1:N
    switch lower(choice)
        case 'debug'
            report{n}=sprintf(format,...
                n,dataset(n).Type,dataset(n).TypeLabel,dataset(n).Title);
        otherwise
            report{n}=sprintf(format,...
                n,dataset(n).TypeLabel,dataset(n).Title);
    end
end

end