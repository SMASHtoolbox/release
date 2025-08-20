% testName Test name against pattern
%
% This function determines if a specified name matches a given pattern.
%    result=matchName(name,pattern)
% The outut "result" is true if the input "name" is compatible with input
% "pattern".  Both inputs must be charater strings: the pattern string
% may contain wildcards (*), but the name string cannot.
%
% These examples illustrate the use of wild cards.
%    testName('file123.txt','*'); % true
%    testName('file123.txt','*.txt'); % true
%    testName('file123.txt','*.dat'); % false
%    testName('file123.txt','file*'); % true
%    testName('file123.txt','file*.tx'); % false
%    testName('file123.txt','file*.tx*'); % true
%    testName('file123.txt','*123*'); % true
%    testName('file123.txt','*13*'); % false
%
% See also General
%

%
% created May 31, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function result=testName(name,pattern)

% manage input
assert(nargin==2,'ERROR: invalid number of inputs');
assert(ischar(name) && ischar(pattern),'ERROR: invalid input(s)');

if any(name == '*')
    error('ERROR: name cannot contain wild cards');
end

name=reshape(name,[1 numel(name)]);
pattern=reshape(pattern,[1 numel(pattern)]);

% look for wildcards
wild=strfind(pattern,'*');
if isempty(wild)
    result=strcmp(name,pattern);
    return
end

change=diff(wild);
assert(all(change > 1),'ERROR: sequential wild cards are not permitted');

% work through the pattern
result=false;
while true
    if isempty(pattern)
        if isempty(name)
            result=true; % success
        end
        break
    elseif isempty(name)
        if strcmp(pattern,'*')
            result=true; % success
        end
        break
    elseif name(1) == pattern(1)
        name=name(2:end);
        pattern=pattern(2:end);
    elseif pattern(1) == '*'
        stop=find(pattern(2:end)=='*',1,'first');        
        if isempty(stop)
            remain=pattern(2:end);            
            pattern='';
        else
            remain=pattern(2:stop);
            pattern=pattern(stop+1:end);
        end
        if isempty(remain)
            name='';
            continue
        end
        M=numel(remain);
        start=strfind(name,remain);
        if start
            name=name(start+M:end);
        else
            break
        end
    else
        break
    end    
end

end