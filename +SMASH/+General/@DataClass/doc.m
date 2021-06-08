% DOC Access documentation for a class object
%
% This method accesses documentation for an existing object, bypassing the
% need for an absolute class name.
%    >> object=Package.Class(...); % create object
%    >> doc(object); % access class documentation
%    >> doc(object,Method); % access method documentation
%
% See also DataClass, help
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function doc(object,topic)

if nargin==1
    doc(class(object));
elseif nargin==2
    doc([class(object) '.' topic]);
else
    error('ERROR: invalid documentation request');
end

end