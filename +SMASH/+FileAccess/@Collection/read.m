% read Read collection files
%
% This methods reads files consistent with the Location, Pattern, Format,
% and Record properties of a collection.
%    data=read(object);
% The output "data" is a cell array of structures obtained from each
% source.
%
% See also Collection, preview, process
%

function data=read(object)

try
    report=preview(object);
catch ME
    throwAsCaller(ME);
end

data=cell(size(report));
for k=1:numel(report)
    try       
        data{k}=packtools.call('readFile',...
                report(k).File,report(k).Format,report(k).Record);   
    catch
        warning('Unable to read:\n   %s',report(k).Summary);
    end
end

end