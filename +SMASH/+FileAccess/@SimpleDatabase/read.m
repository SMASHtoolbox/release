% read Read from database file
%
% This method reads all records from the database file into a structure
% array.
%    >> data=read(object);
%
% See also SimpleDatabase, write
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function data=read(object)

% extract records from database body
[param,~,body]=probe(object);

start=regexp(body,param.Label{1});
stop=start(2:end)-1;
stop(end+1)=numel(body);
record=cell(param.NumberRecords,1);
for m=1:param.NumberRecords
    record{m}=body(start(m):stop(m));        
end

% transfer records to structure
tempData=struct();
for m=1:param.NumberRecords
    for n=1:param.NumberFields        
        [~,start]=regexp(record{m},param.Label{n});
        start=start+1;
        if n<param.NumberFields
            stop=regexp(record{m},param.Label{n+1});
            stop=stop-1;
        else
            stop=numel(record{m});
        end
        value=record{m}(start:stop);
        switch param.DataType{n}
            case 'character'
                value=strtrim(value);
            case 'logical'
                value=sscanf(value,'%d');
                value=logical(value);
            case 'numeric'
                value=sscanf(value,'%g');
        end
        tempData.(param.Name{n})=value;
    end
    if m==1
        data=repmat(tempData,param.NumberRecords,1);
    else
        data(m)=tempData;
    end
end

end