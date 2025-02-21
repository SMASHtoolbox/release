% probe Probe file
%
% This method probes the PDF file's metadata.
%    report=probe(object);
% The output "report" is a structure describing the number of pages,
% encryption status, format version, and so forth.  Empty report fields
% indicate information not defined in the file.
%
% See also PDFfile
%
function report=probe(object)

filename=object.File;
jFile=java.io.File(filename);
document=org.apache.pdfbox.pdmodel.PDDocument.load(jFile);
CU2=onCleanup(@() document.close());

count=document.getNumberOfPages();
report.Pages=count;
report.Encryption='off';
if document.isEncrypted()
    report.Encryption='on';
end
report.Version=document.getVersion();

info=document.getDocumentInformation();
report.Title=char(info.getTitle());
report.Author=char(info.getAuthor());
report.Subject=char(info.getSubject());
report.Productor=char(info.getProducer());
report.Creator=char(info.getCreator());
temp=info.getCreationDate();
report.Created=char(temp.getTime());
temp=info.getModificationDate();
try
    report.Modified=char(temp.getTime());
catch
    report.Modified='';
end

end