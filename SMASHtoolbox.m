%

% notes
function varargout=SMASHtoolbox(varargin)

% manage input
if nargin == 0
    loadSMASH();
elseif strcmpi(varargin{1},'-version')
    if nargout == 0
        aboutSMASH();
    else
      varargout{1}=aboutSMASH();
    end
end

end

%%
function varargout=aboutSMASH(varargin)

location=mfilename('fullpath');
[location,~]=fileparts(location);

% current version number
target=fullfile(location,'SMASHversion');
if exist(target,'file') % release version
    fid=fopen(target,'r');
    data.VersionNumber=fscanf(fid,'%s');
    fclose(fid);
else
    data.VersionNumber='1.1'; % developer version
end

% latest revision date
target=fullfile(location,'*.git');
target=dir(target);
if numel(target)==1
    data.Committed=target.date;
else
    data.Committed='unknown';
end

% handle output
if nargout == 0    
    fprintf('\n');
    fprintf('SMASH toolbox information:\n');
    format='%10s : %s\n';
    fprintf(format,'version',data.VersionNumber);
    fprintf(format,'committed',data.Committed);
    file=fullfile(location,'LICENSE.txt');
    fid=fopen(file,'r');
    while ~feof(fid)
        temp=strtrim(fgets(fid));
        if isempty(temp)
            continue
        end
        fprintf('\n%s\n\n',temp);
        break
    end
    fclose(fid);
    SMASH.System.DocLink('SMASHtoolbox','Toolbox documentation');
else
    varargout{1}=data;
end

end
