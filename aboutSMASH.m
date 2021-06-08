% This function displays version information for the SMASH toolbox.
% Information can be displayed in the command window:
%    >> aboutSMASH
% or returned in a structure.
%    >> a=aboutSMASH;
%
% See also SMASH
%

% 
% created May 15, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised November 17, 2014 by Daniel Dolan
%   -cleaned up interface to *.git subfolder
% revised January 1, 2016 by Daniel Dolan
%   -changed from package function to toolbox utility
function varargout=aboutSMASH(varargin)

location=mfilename('fullpath');
[location,~]=fileparts(location);

% current version number (set by developer)
target=fullfile(location,'SMASHversion');
if exist(target,'file')
    fid=fopen(target,'r');
    data.VersionNumber=fscanf(fid,'%s');
    fclose(fid);
else
    data.VersionNumber='1.1';
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
if nargout==0
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
else
    varargout{1}=data;
end

end