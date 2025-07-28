% process Process collection files
%
% This method applies a user function to files as they are read from
% a collection.
%    data=process(object,userFcn);
% The input "userFcn" must be a handle to a function that accepts a
% structure input and returns one output (of any type). Format-dependent
% structures are passed to the user function immediately after the file
% read, and results from user function are stored in the output cell array
% "data".
%
% Similar behavior can be achieved with the "read" method and post
% processing, but this approach is faster because only one data file
% is loaded into memory at a time.
%
% See also Collection, preview, read
%
function data=process(object,fcn)

% manage input
assert(nargin > 1,'ERROR: no process function specified');
if ischar(fcn)    
    fcn=str2func(fcn);
else
    assert(isa(fcn,'function_handle'),'ERROR: invalid process function')
end

% read and process data
try
    report=preview(object);
catch ME
    throwAsCaller(ME);
end

data=cell(size(report));
for k=1:numel(report)
    try       
        temp=packtools.call('readFile',...
                report(k).File,report(k).Format,report(k).Record);   
    catch
        warning('Unable to read:\n   %s',report(k).Summary);
        continue
    end
    try
        data{k}=fcn(temp);
    catch ME
        throwAsCaller(ME);
    end
end

end