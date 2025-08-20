% revealMethod remove methods from the HiddenMethod list
%
% Usage:
%    >> object=revealMethod(object,name1,name2,...);
%
% See also DataClass, hideMethod
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=revealMethod(object,varargin)

for m=1:numel(varargin)
    if ~ismethod(object,varargin{m})
        error('ERROR: invalid method specified');
    end
    flag=false;
    for n=1:numel(object.HiddenMethods)
        if strcmp(varargin{m},object.HiddenMethods{n})
            flag=true;
            break
        end
    end
    if flag
        object.HiddenMethods(n)=[];
    end
end

end