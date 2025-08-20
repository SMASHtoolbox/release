% PROBE Probe the file associated with a ColumnFile object
%
% Syntax:
%    >> output=probe(object,[delim],[mincol]); 
% The output is a structure with the following fields.
%    -HeaderLines
%    -NumberColumns
%    -Format
%
% See also ColumnFile, read, write
%

function varargout=probe(object,delim,mincol)

if isempty(object.FileName)
    object=select(object);
elseif ~exist(object.FullName,'file')
    error('ERROR: file does not exist');
end

if (nargin<2) || isempty(delim)
    delim={',' ';' '&'};
end

if (nargin<3) || isempty(mincol)
    mincol=1;
end
    
% open file and look for first purely numerical row
fid=fopen(object.FullName,'r');     
finish=onCleanup(@() fclose(fid));

skip=0;
while true
    numcol=0;
    format='';
    temp=fgets(fid);
    in=strtrim(temp);
    while numel(in)>0
        in=strtrim(in); % remove extraneous whitespace       
        % try to read a number
        [~,count,~,next]=sscanf(in,'%g',1);
        if count==1 % numerical value read
            format=[format '%g']; %#ok<AGROW>
            numcol=numcol+1;
            in=in(next:end);
            continue
        end
        % try to read a delimeter
         [value,~,~,next]=sscanf(in,'%c',1);
         switch value
             case delim
                 format=[format '%*1s']; %#ok<AGROW>
                 in=in(next:end);
             otherwise
                 format='';
                 break
         end
    end
    % see if data has been reached
    if isempty(format) || (numcol<mincol)
        skip=skip+1;        
    else
        break
    end
end

report.HeaderLines=skip;
report.NumberColumns=numcol;
report.Format=format;

% handle output
if nargout==0
    disp(report);
else
    varargout{1}=report;
end

end