% SDAbrowse Browse archive file
%
% This program interactively browses Sandia Data Archive (*.sda) files.
%    SDAbrowser % interactive file selection
%    SDAbrowser(filename) % begin with a specific file


function varargout=SDAbrowser(filename)

% manage output
if isdeployed
    varargout{1}=0;
end

% manage input
%mode='append';
if (nargin<1) || isempty(filename)    
    filename=FileBrowser();
    if isempty(filename)
        return
    end
end

createDialog(filename);

end