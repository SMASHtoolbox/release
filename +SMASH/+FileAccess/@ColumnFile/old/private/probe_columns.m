function [numcol,skip,format]=probe_columns(filename,varargin)

% input check
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value input');
options=struct();
options.delim={',' ';' '&'};
options.mincol=1;
for n=1:2:Narg
    name=varargin{n};
    options.(name)=varargin{n+1};   
end

% error checking
if ischar(options.delim)
    options.delim{1}=options.delim;
end
if ~iscell(options.delim)
    error('ERROR: invalid delimeter specified');
end
    
% open file and look for first purely numerical row
fid=fopen(filename,'r');     
finish=onCleanup(@() fclose(fid));

skip=0;
while true
    numcol=0;
    format='';
    in=strtrim(fgets(fid));
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
             case options.delim
                 format=[format '%*1s']; %#ok<AGROW>
                 in=in(next:end);
             otherwise
                 format='';
                 break
         end
    end
    % see if data has been reached
    if isempty(format) || (numcol<options.mincol)
        skip=skip+1;        
    else
        break
    end
end

end