% edit Edit parameter file
%
% This method opens a parameter file in the MATLAB editor
%    edit(object);
%
% See also ParameterFile, show
%

%
% created May 10, 2018 by Daniel Dolan (Sandia National Laboratory)
%
function edit(object)

current=pwd;
CU=onCleanup(@() cd(current));

cd(object.PathName);
edit(object.FileName);

end