% ValidFilename : determine if a string is a valid file name
% (multi-platform)
%
%
% Created 1/24/2007 by Daniel Dolan

function func=ValidFilename(filename)

func=true;
forbiddenA={'?','*','|','"','''','<','>','[',']','+','=',',',';',':','\','/'};
forbiddenB={'?','*','|','"','''','<','>','[',']','+','=',',',';',':'};
first=double(filename(1));
if (first>=65 && first<=90) || (first>=97 && first<=122) % first character is a letter
    for ii=1:numel(forbiddenA)
        if any(filename==forbiddenA{ii})
            func=false;
            return
        end
    end
elseif filename(1)=='.' % may be relative file name
    filename=OSenforcer(filename);
    [pathname,filename,ext]=fileparts(filename);
    if isempty(pathname) % not a relative file name
        func=false;
        return
    end
    filename=[filename ext];
    for ii=1:numel(forbiddenA)
        if any(filename==forbiddenA{ii})
            func=false;
            return
        end 
    end
    for ii=1:numel(forbiddenB)
        if any(pathname==forbiddenB{ii})
            func=false;
            return
        end
    end
else % can't be a valid file
    func=false;
    return
end