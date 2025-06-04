% EXPORT Export object simple data file
%
% This method exports objects to a data file for use outside of the Image
% class. 
%   >> export(object,filename);
% % If the file name has a *.pff extension (case insensitive), the export
% % uses the (binary) Portable File Format.  Any other extension exports the image to
% % a text file with (x y z) columns.
%
% See also IMAGE, store
%

% created October 7, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 18, 2013 by Tommy Ao (Sandia National Laboratories)
% modified January 27, 2015 by Daniel Dolan
%   -added PFF support
% modified February 13, 2015 by Daniel Dolan
%   -removed graphic (jpeg, etc) support
%   -removed SDA support (use export instead)
%   -revised text file support (three data columns)
% modified March 12, 2025 by Tommy Ao
%   -revised '.bmp' '.png' '.jpg' '.jpeg' '.tif' '.tiff' to 16-bit
function export(object,filename,mode)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(ischar(filename),'ERROR: invalid file name');
assert(~isempty(filename),'ERROR: invalid file name');
[~,~,extension]=fileparts(filename);
extension=lower(extension);

if (nargin<3) || isempty(mode)   
    mode='create';
end

% place data into file
switch extension
    case '.pff'
        data=struct();
        data.Grid={object.Grid1 object.Grid2};
        data.GridLabel={object.Grid1Label object.Grid2Label};
        data.Vector={object.Data};
        data.VectorLabel={object.DataLabel};
        data.Type='Image export';
        data.Title=object.Name;
        archive=SMASH.FileAccess.PFFfile(filename);
        write(archive,data,mode);
    case {'.bmp' '.png' '.jpg' '.jpeg' '.tif' '.tiff'}
        z=object.Data;
        %z1=min(z(:));
        %z2=max(z(:));
        %z=(z-z1)/(z2-z1);
        z=uint16(z);
        imwrite(z,filename);
    otherwise       
        x=object.Grid1;
        y=object.Grid2;
        [x,y]=meshgrid(x,y);
        z=object.Data;
        table=[x(:) y(:) z(:)];
        format='%#+.6e %#+.6e %#+.6e\n';
        header{1}=sprintf('Image export on %s',datestr(now));
        header{2}=sprintf('column format: grid1 grid2 data');
        SMASH.FileAccess.writeFile(filename,table,format,header);
end

end