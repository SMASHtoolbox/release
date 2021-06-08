% parseconfig : parse configuration file
%
% This function parses a file into field/value pairs for records defined by
% the configuration. Records are denoted by begin{type}/end{type}
% statements, between which any number of "field = value" statements can be
% inserted.  Braces associate multiple values to a field, such as "field =
% {value1 value2}".  Extraneous white space (such as carriage returns)
% between the field/value declaration is ignored; lines containing only
% white space are ingored unless they occur within a brace pair.  The "%"
% character indicates a comment (from that point to the end of line) ouside
% of a brace pair. 
%
% Usage: 
%   data=parseconfig(filename) returns a cell array of structures as
%   defined by contents of filename.  If filename is an empty string or no
%   input is given, the user is prompted for a file with a dialog box.
%
%   [data,status]=parseconfig(...) returns an structure describing problems
%   encountered during parsing.  The exit mode ('normal', 'cancel', or
%   'error') given in status.exitmode.  A brief message describing the
%   problem (if any) is given in status.message.  This output is intended
%   for use in graphical interfaces, where the user may be unaware that an
%   error has occured. 
%
%   [data,status,filename]=parseconfig(...) returns the absolute name of
%   the configuration file.  This output is helpful when the dialog box is
%   used or the input string contains a relative name (e.g.,
%   "./temp/file.txt")
 
% created 1/22/2007 by Daniel Dolan
function [data,status,filename]=ParseConfig(filename)

% input check
if nargin < 1
    filename='';
end

% default outputs
data={};
status.exitmode='normal';
status.message='';

% generate absolute path name
if isempty(filename) % prompt user for file name
    spec=cell(2,2);
    spec{1,1}= '*.txt;*.TXT;*.dat;*.DAT;*.inp;*.INP;';
    spec{1,2}='Text files';
    spec{2,1}='*.*';
    spec{2,2}='All files';
    [filename,pathname]=uigetfile(spec,'Choose configuration file');
    if isnumeric(filename) || isnumeric(pathname) % user pressed cancel
        status.exitmode='cancel';
        status.message='User pressed cancel';
        fprintf('%s\n',status.message);
        return
    end
else % use specified file name 
    filename=OSenforcer(filename);
    [pathname,filename,ext,ver]=fileparts(filename);
    filename=[filename ext ver];
    if isempty(pathname) % file in current directory
        pathname=pwd;
    else % file name contains path information (could be relative)        
        old=pwd;
        cd(pathname);
        pathname=pwd;
        cd(old);
    end
end
filename=fullfile(pathname,filename);

% see if file exists
if ~exist(filename,'file')
    status.exitmode='error';
    status.message=sprintf('Configuration file %s does not exist',filename);
    fprintf('%s\n',status.message);
    return
end

% see if file can be opened
fid=fopen(filename,'rt');
if fid<0
    status.exitmode='error';
    status.message=sprintf('Unable to open file %s',filename);
    fprintf('%s\n',status.message);    
    return
end

% read configuration file, ignoring comments
newline=sprintf('\n');
config='';
bracelevel=0;
while ~feof(fid)
    textline=fgetl(fid);
    if isnumeric(textline)
        continue
    elseif isempty(sscanf(textline,'%s')) % empty text line
        if bracelevel>0
            config=[config newline];
        end
        continue
    end
    N=numel(textline);
    stop=N;
    for ii=1:N % look for special characters 
        switch textline(ii)
            case '%'
                if bracelevel==0
                    stop=ii-1;
                    break
                end
            case '{'
                bracelevel=bracelevel+1;
            case '}'
                bracelevel=bracelevel-1;
        end
    end
    config=[config textline(1:stop) newline];
end
fclose(fid);

% verify matched braces
if bracelevel~=0
    status.exitmode='error';
    status.message=sprintf('Unbalanced braces in file %s',filename);
    fprintf('%s\n',status.message);
    return
end

% parse configuration
while numel(config)>0
    % probe the begin statement
    [field,count,errmsg,next]=sscanf(config,'%s',1);
    config=config(next:end);
    if isempty(field)
        continue % skip extra space before/between/after records 
    end
    left=find(field=='{');
    right=find(field=='}');
    if strncmp(field,'begin{',6) && ...
            numel(left)==1 && numel(right)==1 && all(left<right)  % valid begin
        type=field((left+1):(right-1));
        startlabel=field;
        stoplabel=sprintf('end{%s}',type);
    else
        status.exitmode='error';
        status.message=sprintf('Improper begin statement: "%s"',field);
        fprintf('%s\n',status.message);
        return
    end
    % run through record entries
    data{end+1}.Type=type;
    bracelevel=0;
    done=false;
    while ~done
        % capture field
        [field,count,errmsg,next]=sscanf(config,'%s',1);
        config=config(next:end);
        if strcmp(field,stoplabel) && bracelevel==0 % stop label found
            done=true;
            continue
        elseif (numel(config)==0) || ...
                (strncmp(field,'begin{',6) && bracelevel==0) % end statement missing
            status.exitmode='error';
            status.message=...
                sprintf('Unable to find matching end statement for "%s"',startlabel);
            return
        elseif ~validfield(field)
            %any(field=='{') || any(field=='}') || any(field=='=')
            status.exitmode='error';
            status.message=...
                sprintf('Invalid field "%s" found',field);
            fprintf('%s\n',status.message);
            return
        end
        % find separator
        [sep,count,errmsg,next]=sscanf(config,'%s',1);
        if strcmp(sep,'=')
            config=config(next:end);
        else
            status.exitmode='error';
            status.message=...
                sprintf('Invalid separator "%s" found',sep);
            fprintf('%s\n',status.message);
            return
        end
        % capture value
        [value,count,errmsg,next]=sscanf(config,'%s',1);
        if value(1)=='{'
            next=find(config=='{',1);
            config=config(next:end);
            bracelevel=0;
            for ii=1:numel(config)
                switch config(ii)
                    case '{'
                        bracelevel=bracelevel+1;
                    case '}'
                        bracelevel=bracelevel-1;
                end
                if bracelevel==0
                    value=config(2:(ii-1));
                    next=ii+1;
                    break
                end
            end            
        end
        config=config(next:end);
        data{end}.(field)=value;
    end    
end

function func=validfield(field)

field=double(field);
number=(field>=48) & (field <=57);
uppercase=(field>=65) & (field<=90);
underscore=(field==95);
lowercase=(field>=97) & (field<=122);

func=false;
if uppercase(1) || lowercase(1)
    if all(number | uppercase | underscore | lowercase)
        func=true;
    end
end