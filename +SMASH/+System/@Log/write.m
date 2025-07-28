% write Write log message
%
% This method writes messages to all log targets.  Messages can be a cell
% array of strings:
%    write(object,message); 
% or a format statement with optional arguments.
%    write(object,format,arg1,...);
% Format operators and special characters can be used in the latter case.
%
% Due to the overhead of each write operation, it is faster to send
% multi-line messages in one call instead of separate calls for each line.
% For example:
%    write(object,'This is \n a multiline message');
% is faster than:
%    write(object,'This is');
%    write(object,' a multiline message');
%
% See also Log, purge
%

% 
% created October 21, 2018 by Daniel Dolan (Sandia National Laboratories) 
%
function write(object,varargin)

% process message
assert(nargin > 1,'ERROR: no write message');

persistent TemporaryFile
if isempty(TemporaryFile)
    TemporaryFile=tempname();
end
fid=fopen(TemporaryFile,'w');

try
    if ischar(varargin{1})
        fprintf(fid,varargin{:});        
    elseif nargin == 2
        new=varargin{1};
        if isstring(new)
            new=cellstr(new);
        else
            assert(iscellstr(new),''); %#ok<ISCLSTR>
        end
        fprintf(fid,'%s\n',new{:});
    end
catch   
    fclose(fid);
    error('ERROR: invalid write statement');
end

fclose(fid);
fid=fopen(TemporaryFile,'r');
new={};
while ~feof(fid)
    new{end+1}=fgetl(fid); %#ok<AGROW>
end
fclose(fid);

for m=1:numel(object.Target)
    N=numel(new);
    target=object.Target{m};   
    if ishghandle(target)
        for n=1:numel(target)
            if ~isvalid(target(n))
                generateWarning(object,'Invalid object handle');
            end
            set(target(n),'Max',2);
            temp=get(target(n),'String');
            if isempty(temp)
                temp=new;
            else
                temp(end+1:end+N)=new;
            end
            set(target(n),'String',temp,'Value',numel(temp));
        end
    elseif strcmp(target,'-stdout')
        fprintf(1,'%s\n',new{:});
    elseif strcmp(target,'-stderr')
        fprintf(2,'%s\n',new{:});
    elseif ischar(target)
        try
            fid=fopen(target,'a');
            fprintf(fid,'%s\n',new{:});           
        catch
            generateWarning(object,'Cannot open log file:\n   %s',target);
        end
        fclose(fid);
    end
end

end