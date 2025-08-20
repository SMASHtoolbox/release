function [x,y]=table2cells(table)

% verify table
if isempty(table)
    x={};
    y={};
    return
end
assert(size(table,2)==2,'ERROR: IsoPoints table must have two columns');

test=isnan(table);
assert(all(test(:,1)==test(:,2)),...
    'ERROR: unmatched NaN in IsoPoints table');

if isnan(table(end,1))
    table=table(1:end-1,:); % remove extra NaN row
end

% read table
[x,y]=deal({});
while ~isempty(table)
    stop=find(isnan(table(:,1)),1,'first');
    if isempty(stop)
        temp=table;
        table=[];
    else
        temp=table(1:stop-1,:);
        table=table(stop+1:end,:);        
    end    
    x{end+1}=temp(:,1); %#ok<AGROW>
    y{end+1}=temp(:,2); %#ok<AGROW>
end

end