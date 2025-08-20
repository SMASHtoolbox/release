% SELECT Select file associated with a File object
%
% This is a generic select method for all subclasses of File.
%
% Syntax:
%    >> object=select(object,[filename]);
%

%
function object=select(object,name)

if (nargin<2) || isempty(name)
    [filename,pathname]=uigetfile(object.FilterSpec,object.DialogTitle);
    if isnumeric(filename)
        error('ERROR: no file selected');
    end
    object.FileName=filename;
    object.PathName=pathname;    
else
    [pathname,filename,ext]=fileparts(name);
    object.FileName=[filename ext];
    if isempty(pathname)
        pathname=fileparts(which(name));
        if isempty(pathname)
            pathname=pwd;
        end
    elseif exist(pathname,'dir')
        current=pwd;
        cd(pathname);
        pathname=pwd;
        cd(current);
    else
        error('ERROR: invalid path or file name specified');   
    end    
    object.PathName=pathname;        
end
object.FullName=fullfile(object.PathName,object.FileName);

[~,~,object.Extension]=fileparts(object.FullName);

end