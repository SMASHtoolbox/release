% smashroot Root directory for the SMASH toolbox
%
% This function returns the system-dependent root directory for the SMASH
% toolbox.
%    location=smashroot();
% The root directory is printed in the command window when no output is
% requested.
%    smashroot();
%
% See also loadSMASH, SMASHtoolbox
%

%
% created December 23, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=smashroot()

location=mfilename('fullpath');
location=fileparts(location);

if nargout == 0
    disp(location);
else
    varargout{1}=location;
end

end