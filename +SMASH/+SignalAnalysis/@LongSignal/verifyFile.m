% verifyFile Verify data file
%
% This method verifies that the data file associated with a LongSignal
% object is valid.
%    result=verifyFile(object);
% The output result is a logical true or false.
%
% Data files are automatically checked during object creation, but this
% method can be called if subsequent changes are made to that file.
%
% See also LongSignal
%

%
% created May 21, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function [result,report]=verifyFile(object)

result=false;

[~,~,ext]=fileparts(object.File);
assert(strcmpi(ext,'.h5'),'ERROR: file extention must be .h5');

try      
    report.Start=h5readatt(object.File,'/Signal','GridStart');
    report.Stop=h5readatt(object.File,'/Signal','GridStop');
    report.Increment=h5readatt(object.File,'/Signal','GridIncrement');
catch
    return
end

result=true;

end