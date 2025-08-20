function table=cells2table(x,y)

table=[];
for n=1:numel(x);
    table=[table; x{n}(:) y{n}(:); nan nan]; %#ok<AGROW>
end
table=table(1:end-1,:); % remove extra NaN row

end