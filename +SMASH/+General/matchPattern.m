% matchPattern Match text against pattern
%
% This function matches text to a specified pattern.  
%    result=matchPattern(list,pattern);
% The input "list" is a character string or a cell array of strings to be
% matched against the input "pattern" (character string).  The pattern may
% contain wild cards (asterisks) for matching against text against one or
% more fragments.  Several examples are shown below.
%    list={'nameA' 'nameB' 'nameC' 'FirstName'};
%    result=matchPattern(list,'name*'); % starts with 'name'
%    result=matchPattern(list,'*C');    % ends with 'C'
% The output "result" is a logical array the same size as "list"; true
% values indicate matching entries.
%
% Matching is case-sensitive by default.  This behavior is controlled with
% an additional input argument.
%    result=matchPattern(list,pattern,'strict'); % case-sensitive (default)
%    result=matchPattern(list,pattern,'loose'); % case-insensitive
%
% See also SMASH.General
% 

%
% created June 5, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function value=matchPattern(list,pattern,strict)

% manage input
assert(nargin > 1,'ERROR: no pattern specified');

if ischar(list)
    list={list};
elseif isstring(list)
    list=cellstr(list);
else
    assert(iscellstr(list),'ERROR: invalid match list'); %#ok<ISCLSTR>
end

assert(ischar(pattern),'ERROR: invalid match pattern');
index=(pattern == '*');
temp=find(index);
assert((numel(temp) < 2) || (diff(temp) > 1),...
    'ERROR: repeated wildcards are not permitted');
if (nargin < 3) || isempty(strict) || strcmpi(strict,'strict')
    strict=true;
elseif strcmpi(strict,'loose')
    strict=false;
else    
    error('ERROR: invalid case mode');
end

% process pattern
block={};
skip=[];

while ~isempty(pattern)
    skip(end+1)=false; %#ok<AGROW>
    k=find(index,2);       
    if isempty(k)
        block{end+1}=pattern; %#ok<AGROW>     
        break
    elseif k(1) == 1
        skip(end)=true;
        if numel(k) == 1
            block{end+1}=pattern(2:end); %#ok<AGROW>
            break
        else
            range=2:(k(2)-1);
            block{end+1}=pattern(range); %#ok<AGROW>
            range=k(2):numel(pattern);
            pattern=pattern(range);
            index=index(range);
        end
    else
        block{end+1}=pattern(1:k(1)-1);  %#ok<AGROW>
        range=k(1):numel(pattern);
        pattern=pattern(range);
        index=index(range);
    end       
end

%  compare list to pattern
N=numel(block);
value=false(size(list));
for m=1:numel(list)
    temp=list{m};    
    for n=1:N
        if (n == N) && isempty(block{n}) % wildcard termination
            temp='';
            success=true;
            break
        end     
        success=false;
        L=numel(block{n});                
        while ~isempty(temp)
            if strict
                match=strncmp(temp,block{n},L);
            else
                match=strncmpi(temp,block{n},L);
            end
            if match
                temp=temp(L+1:end);
                success=true;
                break
            elseif skip(n)
                temp=temp(2:end);
            else
                break                
            end
        end          
        if ~success
            break
        end        
    end
    if success && isempty(temp)
        value(m)=true;
    end
end
   
end