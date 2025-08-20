% isScript Determine if file is a MATLAB script
%
% This method determines if a specified file is a MATLAB script.
%    value=isScript(filename)
% The output "value" is true for traditional script files ('*.m') and live
% script files ('*.mlx').  Function/class definitions and any other file
% type (including invalid/missing files) return false.
%
% See also script
%
%

%
% created January 10, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function value=isScript(filename)

% manage input
assert(nargin > 0,'ERROR: no file name specified');
assert(ischar(filename),'ERROR: invalid file name');

% check file
value=false;
start=pwd;
switch exist(filename,'file')
    case 2
        try
            [location,name,ext]=fileparts(filename);
            cd(location);
            nargin([name ext]);
        catch
            value=true;
        end
end
cd(start);

end