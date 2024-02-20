function [img, dx, X, dy, Y ] = read_ditabis(varargin)
%%  [img, dx, X, dy, Y ] = read_ditabis(varargin)
%
%   This function reads a ditabis image plate file and extracts the image
%   as well as the x- and y-scales and resolutions.  If no input argument
%   is passed it will ask you to choose a file.  If an input argument is
%   passed it must be the full file name, including path and extension.  If
%   no path is included it will look for the file in your current
%   directory.  If no extension is included, it will append a .tif
%   extension.  If an extension is included, but it is not .tif, the
%   program will exit.  If no file is found matching the name, you will
%   recieve an error as well as a warning indicating that the file does not
%   exist.
%
%   Output Arguments
%       img - NxM double array containing image data
%       dx, dy - image resolution in microns
%       X - Mx1 array of x-values in microns
%       Y - Nx1 array of y-values in microns
%
%   Created by: Patrick Knapp (pfknapp@sandia.gov)
%   Created on: 7/9/2015
%%
if isempty(varargin)
    [filename, pathname] = uigetfile('*.tif');
    File = strcat(pathname,filename);
else
    FileTemp = varargin{1};
    [~, ~, ext] = fileparts(FileTemp);
    if strcmp(ext,'.tif')
        File = FileTemp;
    elseif strcmp(ext,'.IPH')
        File = strcat(FileTemp,'.tif');
    elseif strcmp(ext,'.IPL')
        File = strcat(FileTemp,'.tif');
    elseif strcmp(ext,'')
        File = strcat(FileTemp,'.tif');
    else warning(' TIFF file required ')
    end
end

fid = fopen(File);

if fid <0
    warning(' File %s Does not Exist ',File)
else
    fclose(fid);
    info = imfinfo(File);
    
    dx = 1/info.XResolution*25400;
    dy  =1/info.YResolution*25400;
%    dx = 1/info.XResolution*25.4;
%    dy  =1/info.YResolution*25.4;
    
    X = dx*(0:info.Width-1);
    Y = dy*(0:info.Height-1);
    
    img = imread(File);
    img = double(img);
end

end

