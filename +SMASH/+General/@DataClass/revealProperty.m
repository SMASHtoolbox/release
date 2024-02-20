% revealProperty Remove properties from the ConcealedProperties list
%
% Usage:
%    >> object=revealProperty(object,name1,name2,...);
%
% See also DataClass,hideProperty
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=revealProperty(object,varargin)

for m=1:numel(varargin)
    if ~isprop(object,varargin{m})
        error('ERROR: invalid property specified');
    end
    flag=false;
    for n=1:numel(object.ConcealedProperties)
        if strcmp(varargin{m},object.ConcealedProperties{n})
            flag=true;
            break
        end
    end
    if flag
        object.ConcealedProperties(n)=[];
    end
end

end