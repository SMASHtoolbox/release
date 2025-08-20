% show Show parameter file
%
% This method shows a parameter file in the command window.
%    show(object);
%
% See also ParameterFile, edit
%

%
% created May 10, 2018 by Daniel Dolan (Sandia National Laboratory)
%
function show(object)

current=pwd;
CU=onCleanup(@() cd(current));

cd(object.PathName);
type(object.FileName);

end