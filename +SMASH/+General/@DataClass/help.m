% HELP Access help for a class object
%
% This method accesses help for an existing object, bypassing the
% need for an absolute class name.
%    >> object=Package.Class(...); % create object
%    >> help(object); % access class help
%    >> help(object,Method); % access method help
%
% See also DataClass, doc
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function help(object,topic)

if nargin==1
    help(class(object));
elseif nargin==2
    help([class(object) '.' topic]);
else
    error('ERROR: invalid help request');
end

end