% This method gets custom line property values
%
%    >> get(object,name);
%

% created August 3, 2013 by Daniel Dolan (Sandia National Laboratories)
function output=get(object,name)

if (nargin<2) || isempty(name)
    get(object.Handle);
else
    output=get(object.Handle,lower(name));          
end

end