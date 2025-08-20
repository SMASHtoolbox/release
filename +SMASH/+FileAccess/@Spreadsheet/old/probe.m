function varargout=probe(object)

try
    [status,sheet]=xlsfinfo(object.FullName);
catch
    error('ERROR: cannot find spreadsheet file');
end
assert(~isempty(status),'ERROR: cannot read spreadsheet file');


if nargout == 0
    fprintf('Worksheets:\n');
    fprintf('   %s\n',sheet{:});
else
    varargout{1}=sheet;
end

end