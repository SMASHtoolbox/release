% wipe Wipe file contents
%
% This method wipes the contents of a file without deleting it.
%    wipe(object);
%

function wipe(object,prompt)

% manage input
if (nargin < 2) || isempty(prompt) || strcmpi(prompt,'-prompt')
    prompt=true;
elseif strcmpi(prompt,'-noprompt')
    prompt=false;
else
    error('ERROR: invalid prompt mode');
end

% prompt user 
if prompt
    fprintf('Wiping the contents of "%s"\n',object.FileName);
    choice=input('   Type "yes" to continue : ','s');
    if ~strcmpi(choice,'yes')
        return
    end
end

% perform wipe
target=fullfile(object.PathName,object.FileName);
try
    fid=fopen(target,'w');
catch
    error('ERROR: cannot erase file');
end

fclose(fid);

end