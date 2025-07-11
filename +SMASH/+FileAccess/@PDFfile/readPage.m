% readPage Read page image
%
% This method reads a page image from a PDF file.  
%    readPage(object);
% The first page is read by default at a resolution of 300 dots per inch.
% Other pages and resolutions can also be specified.
%    readPage(object,page,DPI);
% The input "page" is an integer matching any valid page number in the
% file.  The input "DPI" must be a number >= 50.  
%
% Page images are displayed in a new figure by default.  Requesting an output:
%    data=readPage(...);
% returns a RGB array without displaying the image.
%
% See also PDFfile, readText
%

function varargout=readPage(object,page,DPI)

assert(isfile(object.File),'ERROR: file does not exist');

filename=object.File;
jFile=java.io.File(filename);
document=org.apache.pdfbox.pdmodel.PDDocument.load(jFile);
CU=onCleanup(@() document.close());

count=document.getNumberOfPages();
valid=1:count;
if (nargin < 2) || isempty(page)
    page=1;
else
    assert(isnumeric(page) && isscalar(page) && any(page == valid),...
        'ERROR: invalid page number');
end

if nargin < 3
    DPI=300;
else
    assert(isnumeric(DPI) && isscalar(DPI) && (DPI >= 50),...
        'ERROR: invalid DPI');
end

pdfRenderer = org.apache.pdfbox.rendering.PDFRenderer(document);
ImageType=org.apache.pdfbox.rendering.ImageType.RGB();
bim=pdfRenderer.renderImageWithDPI(page-1,DPI,ImageType);
target=[tempname() '.png'];
org.apache.pdfbox.tools.imageio.ImageIOUtil.writeImage(bim,target,DPI);

data=imread(target);
if nargout == 0
    figure();
    imshow(data);
    axis image;
else
    varargout{1}=data;
end

end