% userpath Determine user path
%
% This function determines the directories accessible to MATLAB that are
% not part of MATLAB itself.
%    list=userpath();
% The output "list" is a cell array of text strings showing the current
% user path.  This list is considerably shorter than the results from
% MATLAB's path command.
%
% Calling this function with no output:
%    userpath();
% prints the user path list in the command window.
%
% See also path, userdir, username, path
%

%
% created May 3, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=userpath()

% search path for MATLAB directories
source=matlabroot();
list=regexp(path,pathsep,'split');
keep=true(size(list));
for k=1:numel(list)
    if strfind(list{k},source)
        keep(k)=false;
    end
end
list=list(keep);
list=list(:);

% manage output
if nargout == 0
    fprintf('\tUSERPATH\n');
    fprintf('\t%s\n',list{:});
else
    varargout{1}=list;
end


end