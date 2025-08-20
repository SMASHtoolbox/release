% SelectImageFile : prompt user to select file from supported formats

% created October 15, 2013 by Tommy Ao (Sandia National Laboratories)
%
function filename=SelectImageFile()

ccd='*.spe;*.SPE;*.imd;*.IMD;*.img;*.IMG';
film='*.img;*.IMG;*.hdf;*.HDF';
plate='*.img;*.IMG;';
standard='*.bmp;*.BMP;*.jpg;*.JPG;*.jpeg;*.JPEG;*.png;*.PNG;*.tif;*.TIF;*.tiff;*.TIFF';

filter={};
filter{end+1,1}=[ccd film plate];
filter{end,2}='Supported file types';
filter{end+1,1}=ccd;
filter{end,2}='CCD binary files (*.spe,*.imd,*.img)';
filter{end+1,1}=film;
filter{end,2}='Film scan binary files (*.hdf,*.img)';
filter{end+1,1}=plate;
filter{end,2}='Image plate binary files (*.img)';
filter{end+1,1}=standard;
filter{end,2}='Standard image files (*.bmp,*.jpg;*.jpeg;*.png;*.tif;*.tiff)';
filter{end+1,1}='*.*';
filter{end,2}='All files (*.*)';
[filename,pathname]=uigetfile(filter,'Select image file');
if isnumeric(filename)
    return
end
filename=fullfile(pathname,filename);

end