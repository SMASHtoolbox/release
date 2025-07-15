% workspace2sda Save the current workspace to an archive
%
% This function saves all variables in the current workspace to an archive
% file (*.sda).  The archive can be specified manually:
%    workspace2sda(file);
% or selected interactively.
%    workspace2sda();
% Each variable is stored as a record with the same name. 
%
% Name clashes between variables and existing records are resolved by
% appending the former with an underscore and number.  For example, if the
% variable "a" is added to archive that already has a record with that
% label, the new record is labelled "a_1".  This function generates a
% warning if any name clash occurs.
%
% Lossless compression is not used by default, but can be requested by
% passing a second input.
%    workspace2sda(file,deflate); % deflate can be 0-9
% Higher deflate values take longer but result in smaller archive files.
%
% The output of this function, if requsted, is the actual record labels
% added to the archive.
%    actual=workspace(...)
%
% See also SMASH.FileAccess, sda2workspace
%

%
% created November 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=workspace2sda(file,deflate)

% manage input
if (nargin < 1) || isempty(file)
    sf=SMASH.MUI.SelectFile;
    sf.Title='Select archive file';
    sf.Filter='*.sda';
    sf.EnableFilter='on';
    sf.HiddenControl='off';
    file=launch(sf);
    if isnumeric(file)
        return
    end
end

if (nargin<2) || isempty(deflate)
    deflate=0;
end
assert(any(deflate==0:9),'ERROR: invalid defflate value');

% save workspace variables
variable=evalin('caller','whos');
clash=false;
for n=1:numel(variable)
    name=variable(n).name;
    description=sprintf('Workspace variable "%s"',name);
    command=sprintf('SMASH.FileAccess.writeFile(''%s'',''%s'',%s,''%s'',%d)',...
        file,name,name,description,deflate);
    try
        evalin('caller',command)
    catch
        clash=true;
        iteration=0;
        while true
            iteration=iteration+1;
            new=sprintf('%s_%d',name,iteration);
            command=sprintf('SMASH.FileAccess.writeFile(''%s'',''%s'',%s,''%s'',%d)',...
                file,new,name,description,deflate);
            try
                evalin('caller',command);
                break
            catch
                continue
            end
        end
    end    
end

if clash
    warning('SDA:NameClash','Label clash(es) detected and avoided');
end

% manage output
if nargout>0
    varargout{1}=variable;
end

end