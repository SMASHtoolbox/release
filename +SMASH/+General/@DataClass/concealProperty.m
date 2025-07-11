% hideProperty Add properties to the ConcealedProperties list
%
% Usage:
%    >> object=hideProperty(object,name1,name2,...)
%
% See also DataClass, revealProperty
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=concealProperty(object,varargin)

for m=1:numel(varargin)
    if ~isprop(object,varargin{m})
        error('ERROR: invalid property specified');
    end
    flag=true;
    for n=1:numel(object.ConcealedProperties)
        if strcmp(varargin{m},object.ConcealedProperties{n})
            flag=false;
            break
        end
    end
    if flag
        object.ConcealedProperties{end+1}=varargin{m};
    end    
end

object.ConcealedProperties=sort(object.ConcealedProperties);

end