% extract Extract worksheet data
%
% This method extracts data from a worksheet.
%    data=extract(object); % first sheet or text file
%    data=extract(object,sheet); % specified sheet
% For Excel files, sheets can be specified by name or numeric index.
%
% Extracted data is return as a cell array of character strings.  For
% continuous selections, this array is the same shape as the highlighted
% cell block.  Discontinuous selections are concatenated into rectangular
% arrays when possible, e.g. two columns spanning the same rows separated
% by one or more columns are returned as a two-column array.  All other
% selections are returned as a column array sweeping through the
% selected cell columns.
% 
% See also Spreadsheet, read, view
%

%
% created January 23, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function selection=extract(object,varargin)

try
    db=view(object,varargin{:});
catch ME
    throwAsCaller(ME);
end

db.Name='Worksheet extract';
ht=db.Controls(end);
index=[];
set(ht,'CellSelectionCallback',@select)
    function select(varargin)
        event=varargin{2};
        index=event.Indices;
    end

h=addblock(db,'button',{'Done' 'Cancel'});
set(h(1),'Callback',@done)
    function done(varargin)
        data=get(ht,'Data');
        origin=index(1,:);        
        M=max(index(:,1))-origin(1)+1;
        N=max(index(:,2))-origin(2)+1;
        selection=cell(M,N);
        hit=false(M,N);
        for k=1:size(index,1)
            m=index(k,1);
            ms=m-origin(1)+1;
            n=index(k,2);
            ns=n-origin(2)+1;
            selection{ms,ns}=data{m,n};
            hit(ms,ns)=true;
        end        
        if ~all(hit(:))
            filled=all(hit,1);
            empty=~any(hit,1);
            if all(filled | empty)
               selection=selection(:,filled); 
            else
                selection=selection(hit);
            end
        end        
        delete(h);
    end
set(h(2),'Callback',@cancel)
    function cancel(varargin)
        selection={};
        delete(h);
    end

locate(db,'center');
show(db);

waitfor(h(1));
delete(db);

end