% ColumnReader : extract column data from a file
%
% This function extracts numerical data columns from a text file.  Columns
% are denoted by white space and/or delimeter characters (',', ';', and '&'
% by default).  A header containing any valid ASCII character may be
% placed at the beginning of the file.  The program distinguishes between
% header lines and data lines by the fact that the latter is comprised
% soley of numerical values, white space, and delimeters.  The file may
% contain any number of data columns (with arbitrary width), but consistent
% column separators are expected from one line to the next.
%
% Usage: 
%    [data,header,filename]=ColumnReader(filename,delim,mincolumn);
%
% Input:
%    filename : file name (user prompted if omitted)
%    delim : custom delimeter character(s)
% 
% Output:
%    data : numeric column data (2D double array)
%    header : header lines (1D cell array)
%    filename : import file (character array)

% created 7/6/2005 by Daniel Dolan (Sandia National Labs)
%
% updated 3/28/2006 by Daniel Dolan
%    -implemented user choice of delim
%    -added filename output (useful when uidialog is called)
%    -changed '%*c' to '%*s' to fix bug in MATLAB R2006a
% updated 3/19/2007 by Daniel Dolan
%    -streamlined file header logic
%    -revised documentation
% updated 1/20/2010 by Daniel Dolan
%    -added an extra input "mincol" to skip header line
% updated 6/25/2010 by Daniel Dolan
%    -removed partial line reads at the end of a file scan
% updated 10/11/2010 by Daniel Dolan
%    -gracefully handle user cancel of uigetfile
function [data,header,filename]=ColumnReader(filename,delim,mincolumn)

% input check
if (nargin<1) || isempty(filename)
    [filename,pathname]=uigetfile('*.*','Select data file');
    if isnumeric(filename)        
        data=[];
        [header,filename]=deal('');
        return
    end
    filename=fullfile(pathname,filename);
end

if (nargin<2) || isempty(delim)
    delim={',' ';' '&'};
end
if ~iscell(delim) && ~ischar(delim)
    error('ERROR: invalid delimeter specified');
end

if (nargin<3) || isempty(mincolumn)
    mincolumn=0;
end
    
% open file for reading
fid=fopen(filename,'rt');     

% find the first numerical column
Nheader=0;
%done=false;
format='';
while isempty(format)
    Ncolumn=0;
    format='';
    in=fgets(fid);
    while numel(in)>0
        in=strtrim(in); % remove extraneous whitespace
        % try to read a number
        [value,count,err,next]=sscanf(in,'%g',1);
        if count==1 % numerical value read
            format=[format '%g'];
            Ncolumn=Ncolumn+1;
            in=in(next:end);
            continue
        end
        % try to read a delimeter
         [value,count,err,next]=sscanf(in,'%c',1);
         switch value
             case delim
                 format=[format '%*1s'];
                 in=in(next:end);
             otherwise
                 Nheader=Nheader+1;
                 format='';
                 break
         end
    end
    if Ncolumn<mincolumn
        Nheader=Nheader+1;
        format='';
    end
end

% read header and column data
frewind(fid);
header=cell([1 Nheader]);
for ii=1:Nheader
    header{ii}=fgetl(fid);
end
[data,count]=fscanf(fid,format,[Ncolumn inf]);
if rem(count,Ncolumn)~=0 % partial read
    data=data(:,1:end-1);
end
data=transpose(data);

% close the file
fclose(fid);