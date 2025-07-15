% sda2workspace Load archive into the current workspace
%
% This function loads records from an archive file (*.sda) into the current
% workspace.  The archive can be specified manually:
%    sda2workspace(file);
% or selected interactively.
%    sda2workspace();
% Each variable is named after the record it's create from, as much as is
% possible.  MATLAB has stricter requirements on variable naming than SDA
% does for labeling, so some differences may be found.  For example, white
% space between two strings ('my variable') is replaced with an underscore
% ('my_variable').  A warning is issued when any invalid variable names are
% found in the archive.
%
% Name clashes between records and and existing variables are resolved by
% appending the former with an underscore and number.  For example, if a
% record labeled "a" is added to archive that already has a variable with
% that label, the new variable is labelled "a_1".  This function generates
% a warning if any name clash occurs.
%
% The outputs of this function, if requested, are the actual variable names
% and record descriptions.
%    [actual,description]=sda2workspace(...).
%
% See also SMASH.FileAccess, workspace2sda
%

%
% created November 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=sda2workspace(file)

% manage input
if (nargin < 1) || isempty(file)
    sf=SMASH.MUI.SelectFile;
    sf.Title='Select archive file';
    sf.Filter='*.sda';
    sf.EnableFilter='on';
    sf.FileControls='off';
    sf.HiddenControl='off';
    file=launch(sf);
    if isnumeric(file)
        return
    end
end

% read records from the archive
badname=false;
clash=false;
archive=SMASH.FileAccess.SDAfile(file);
[label,~,description]=probe(archive);
for m=1:numel(label)
    % generate valid variable name
    name=sprintf('previous_%s',strtrim(label{m}));    
    for n=10:numel(name)
        if ~isvarname(name(1:n))
            name(n)='_';
        end
    end
    if isvarname(name(10:end))
        name=name(10:end);
    end  
    if ~strcmp(name,label{m})
        badname=true;
    end
    % prevent variable overwrite    
    command=sprintf('exist(''%s'',''var'')',name);
    result=evalin('caller',command);
    if result == 1
        clash=true;
        iteration=0;
        while true        
            iteration=iteration+1;
            new=sprintf('%s_%d',name,iteration);
            command=sprintf('exist(''%s'',''var'')',new);
            result=evalin('caller',command);
            if result ~= 1
                name=new;
                break
            end
        end
    end        
    % load record into variable
    temp=SMASH.FileAccess.readFile(file,'sda',label{m});
    assignin('caller',name,temp);  
    label{m}=name;
end

if badname
     warning('SDA:BadName','Invalid variable name(s) detected and corrected');
end

if clash
    warning('SDA:NameClash','Variable name clash(es) detected and avoided');
end

% manage output
if nargout > 0
    varargout{1}=label;
    varargout{2}=description;
end

end