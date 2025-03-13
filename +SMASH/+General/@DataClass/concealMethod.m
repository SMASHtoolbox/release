% hideMethod Add method(s) to the ConcealedMethod list
%
% Usage:
%    >> object=hideMethod(object,name1,name2,...);
%
% See also DataClass, revealMethod
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=concealMethod(object,varargin)

for m=1:numel(varargin)
    if ~ismethod(object,varargin{m})
        error('ERROR: invalid method specified');
    end
    flag=true;
    for n=1:numel(object.ConcealedMethods)
        if strcmp(varargin{m},object.ConcealedMethods{n})
            flag=false;
            break
        end
    end
    if flag
        object.ConcealedMethods{end+1}=varargin{m};
    end    
end

object.ConcealedMethods=sort(object.ConcealedMethods);

end