% readText Read text data
% 
% This method reads all text data from a PDF file.
%    data=readText(object);
% The output "data" is a character array.  
%
% NOTE: text layout strongly depends on file construction!  Extracted text
% may have different white spacing and line structure than the file shows in
% a PDF viewer.
%
% See also PDFfile, readPage
%
function data=readText(object)

filename=object.File;
jFile=java.io.File(filename);
document=org.apache.pdfbox.pdmodel.PDDocument.load(jFile);
stripper=org.apache.pdfbox.text.PDFTextStripper();
data=stripper.getText(document);
document.close()

data=char(data);

end