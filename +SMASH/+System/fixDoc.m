% fixDoc Fix custom documentation display
%
% This function changes how MATLAB displays custom documentation.  Prior to
% release 2013b, function/class/package documentation produced outside of
% the MathWorks was displayed in the MATLAB web browser.  More recent
% releases display custom documentation in MATLAB's help browser along with
% standard documentation.  All hyperlinks in custom documentation now
% create new browser tabs, preventing forward/backward browsing and
% eventually making the help browser unusable.  Standard documentation
% hyperlinks do *not* create extra browser tabs, so many users may not have
% noticed the change.
%
% Calling this function enables the pre-2013b behavior of displaying
% custom documentation in the MATLAB web browser.
%     >> fixDoc;
% Documentation hyperlinks open documents in the same tab, and
% documentation calls are displayed in the active tab.  New tabs are
% only created when the user presses the "+" sign at the top of the
% browser.
% 
% NOTE: this function modifies the "helpwin.m" file in the root MATLAB
% directory.  The modification persists between MATLAB sessions.  To
% restore the default behavior:
%    >> fixDoc('restore');
%
% See also doc
%

%
% created September 14, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function fixDoc(mode)

% manage input
if (nargin<1) || isempty(mode)
    mode='fix';
end
assert(ischar(mode),'ERROR: invalid mode requested');

% 
original=which('helpwin');
[location,~,~]=fileparts(original);
backup=fullfile(location,'helpwin_backup.m');

% make sure this isn't Windows
if ispc
    warning('SMASH:System','Windows will not let this command work');
    fprintf('To manually fix documentation display:\n');
    fprintf('\t-Open the file: \n\t\t%s\n',original);
    fprintf('\t-Find the command "web(htmlFile, ''-helpbrowser'')"\n');
    fprintf('\t\tThis will be near the end, in the displayFile function \n');
    fprintf('\t-Replace the command with "web(htmlFile)"\n');    
    return
end

% restore mode
if strcmpi(mode,'restore')
    if exist(backup,'file')
        movefile(backup,original,'f');
        fprintf('"helpwin.m" file restored\n');
    end
    clear('helpwin');
    return
end

% fix mode
assert(strcmpi(mode,'fix'),'ERROR: invalid mode requested');
copyfile(original,backup,'f');

copy=fullfile(location,'helpwin_copy.m');
fidA=fopen(original,'r');
fidB=fopen(copy,'w');

found=false;
while ~feof(fidA)
    temp=fgetl(fidA);
    if strcmp(strtrim(temp),'web(htmlFile, ''-helpbrowser'');')
        fprintf(fidB,'%% Modification on %s\n',datestr(now));
        fprintf(fidB,'%% %s\n',temp);
        fprintf(fidB,'%s\n','web(htmlFile);');
        found=true;
    else
        fprintf(fidB,'%s\n',temp);
    end
end

fclose(fidA);
fclose(fidB);

if found
    movefile(copy,original,'f');
    fprintf('"helpwin.m" file modified\n');
    clear('helpwin');
else
    fprintf('Modification already made or not required\n');
    delete(copy);
end

end