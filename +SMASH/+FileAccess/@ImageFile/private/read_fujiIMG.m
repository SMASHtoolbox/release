% imgread : read IMG file created by a Fuji image plate scanner
%
% Usage:
% >> [data,info]=imgfujiread(file);

% This procedure reads a FUJI format file for the image plate (IP) data and 
% outputs a PSL (Photo-Stimulable Luminenscence) dose equivelent file.  
% The data for the conversion and the image parameters are read from the 
% Fuji .INF header file.  The image data itself must be in a .IMG file of 
% the same name as the header file.  The units of the output are PSL.
% 
% created August 28, 2013 by Tommy Ao (Sandia National Labs)
% based on imgread.m function written by Dan Dolan
% modified October 29, 2013 by Tommy Ao
%
function [data,info]=read_fujiIMG(file)

% locate files
[pathname,filename,ext]=fileparts(file);
switch ext
    case '.img'
        headerfile=fullfile(pathname,[filename '.inf']);
        datafile=file;
    case '.IMG'
        headerfile=fullfile(pathname,[filename '.INF']);
        datafile=file;
    case '.inf'
        headerfile=file;
        datafile=fullfile(pathname,[filename '.img']);
    case '.INF'
        headerfile=file;
        datafile=fullfile(pathname,[filename '.IMG']);
    otherwise
        error('ERROR: invalid file type specified');
end

if ~exist(headerfile,'file')
    error('ERROR: header file \n\t%s\ndoes not exist!',headerfile);
elseif ~exist(datafile,'file')
    error('ERROR: data file \n\t%s\ndoes not exist!',headerfile);
end

% read the header file
header=textread(headerfile, '%s', 'delimiter', '\n'); %#ok<*REMFF1>
info=header;
FileType = header{1}; % FileType = 'BAS_IMAGE_FILE'
FileTitle = header{2}; % FileTitle = 'FUJI filename'
ScanDimension = header{3}; % ScanDimensions = Scan Dimensions'
Xresolution=str2double(header{4}); % Xresolution = Resolution of X Points in image (microns)
Yresolution=str2double(header{5}); % Yresolution = Resolution of X Points in image (microns)
BitDepth=str2double(header{6}); % BitDepth = 8 or 16 bit
Nx=str2double(header{7}); % Nx = Number of X Points in image
Ny=str2double(header{8}); % Ny = Number of Y Points in image
Sensitivity=str2double(header{9}); % Sensitivity = 1000, 4000, or 10000
Latitude=str2double(header{10}); % Latitude = 4 or 5
GradLevels = 2^BitDepth; % Number of levels

% read the data file
data=multibandread(datafile,[Ny,Nx,1],'uint16',0,'bsq','ieee-be'); % Read 16 bit [nx ny] matrix

% convert to PSL
data=(Xresolution*Yresolution/10000)*(4000/Sensitivity)*(10.^(Latitude*(data/GradLevels-0.5))); % convert to PSL units (Photo-Simulated Luminescence)
minvalue=(Xresolution*Yresolution/10000)*(4000/Sensitivity)*(10.^(Latitude*(-0.5)));
data(data==minvalue)=0;

end