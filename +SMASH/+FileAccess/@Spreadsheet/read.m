% read Read worksheet data
%
% This method reads all data from one worksheet.
%    data=read(object,sheet);
% The input "sheet" should be omitted when reading text files; omitting this
% input in an Excel file automatically references the first worksheet.
% Worksheets can be specified by name ('Sheet1') or numeric index (1).
%
% The output "data" is a cell array of character strings.  Empty cells at
% the top and left side of the worksheet are kept to maintain proper
% indexing: the first row of "data" *always* matches the first row of the
% worksheet.  Empty columns on the bottom and right side of the worksheet
% are removed.
%
% Requesting a second output:
%    [data,sheet]=read(object,sheet);
% returns the name of the worksheet that was read from.  An empty character
% string is returned when reading text files.
%
% See also Spreadsheet, extract, view
%

%
% created January 23, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function [data,sheet]=read(object,sheet)

% read data
switch lower(object.Extension)
    case {'.xls' '.xlsx'}
        list=object.Sheet;
        if (nargin < 2) || isempty(sheet)
            sheet=list{1};
        elseif isnumeric(sheet)
            assert(any(sheet == 1:numel(list)),'ERROR: invalid sheet index');
            sheet=list{sheet};
        else
            assert(ischar(sheet),'ERROR: invalid sheet name');
            match=false;
            for k=1:numel(list)
                if strcmp(sheet,list{k})
                    match=true;
                    break
                end
            end
            assert(match,'ERROR: sheet not found');
        end
        [~,~,data]=xlsread(object.FullName,sheet);
        %data=readcell(object.FullName,spreadsheetImportOptions('Sheet',sheet));
    otherwise
        assert(nargin == 1,'ERROR: sheets not supported in this file type');
        try
            data=readtable(object.Fullname,'ReadVariableNames',false);
        catch ME
            throwAsCaller(ME);
        end
        data=table2cell(data);
        sheet='';
end

% process data
columns=size(data,2);
while size(data,1) > 0
    empty=true;
    for m=1:columns
        if ~isnan(data{end,m})
            empty=false;
            break
        end
    end
    if empty
        data=data(1:end-1,:);
    else
        break
    end
end

rows=size(data,1);
while size(data,2) > 0
    empty=true;
    for n=1:rows
        if ~isnan(data{n,end})
            empty=false;
            break
        end
    end
    if empty
        data=data(:,1:end-1);
    else
        break
    end
end

for k=1:numel(data)
    if isnan(data{k})
        data{k}='';
    elseif isnumeric(data{k})
        data{k}=num2str(data{k});
    end
end

end