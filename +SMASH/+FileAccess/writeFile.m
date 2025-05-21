% WRITEFILE Write data to a file
%
% This method writes data from MATLAB to a file in 'column', 'dig', or
% 'sda' format based on the specified file extension.  Any extension other
% than *.dig or *.sda uses the 'column' or 'block format based on the
% input "table" (numeric matrix or cell array of numeric matrices,
% respectively).
%    >> writeFile('myfile.txt',table,[format],[header]); %
% An optional format string can be passed to control how the data table is
% written ; MATLAB's "fprintf" documentation describes how format strings
% are constructed.  An optional cell array "header" can also be specified;
% each element of this array is printed as a line at the beginning of the
% file.
%
% The 'dig' format is used for *.dig files, which requires numerical arrays
% "time" and "signal" of the same size.
%    >> writeFile('myfile.dig',time,signal);
%
% The 'sda' format is used for *.sda files, which require a text input
% "label" followed by the data.
%    >> writeFile('myfile.sda',label,data,[description],[deflate]);
% Description and deflate inputs are optional.
%
% By default, users are prompted to replace single-record files that
% already exist; existing *.sda files are appended if the requested label
% is unique.  Existing files can be automatically overwritten by passing
% '-overwrite' at any location after the file name.
%   >> writeFile(filename,'-overwrite',...);
% The existing file is deleted before the write operation; previous records
% in a *.sda file are discarded.
% 
% See also SMASH.FileAccess, fprintf, SDAfile
%

%
% created October 31, 2013 by Daniel Dolan (Sandia National Laboratories)
% updated April 11, 2014 by Daniel Dolan
%    -Revised documentation, adding links 
%
function writeFile(filename,varargin)

% handle file name
UseClipboard=false;
if (nargin<1) || isempty(filename)
    [filename,pathname]=uiputfile({'*.*','All files'},'Select file');
    if isnumeric(filename)
        error('ERROR: no file selected');
    end
    filename=fullfile(pathname,filename);
elseif strcmpi(filename,'-clipboard')
    filename=[tempname() '.txt'];
    UseClipboard=true;
end

% handle overwrite mode
Narg=numel(varargin);
keep=true(1,Narg);
for n=1:Narg
    if strcmp(varargin{n},'-overwrite')
        if exist(filename,'file')
            delete(filename);
        end
        keep(n)=false;
    end
end
varargin=varargin(keep);

% write file
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.dig'
        object=SMASH.FileAccess.DIGfile(filename);
        write(object,varargin{:});    
    case '.sda'
        object=SMASH.FileAccess.SDAfile(filename);
        insert(object,varargin{:});        
    otherwise
        if isnumeric(varargin{1})
            object=SMASH.FileAccess.ColumnFile(filename);
        elseif iscell(varargin{1})
             object=SMASH.FileAccess.BlockFile(filename);
        else
            error('ERROR: invalid table input');
        end
        write(object,varargin{:});
        if UseClipboard
            fid=fopen(filename,'r');
            temp=fscanf(fid,'%c');
            fclose(fid);
            clipboard('copy',temp);
        end
end

end