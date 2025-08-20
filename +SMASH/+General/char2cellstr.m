% UNDER CONSTRUCTION
% This function converts a character array into a cell array of character
% vectors.  New line characters are used to separate entries from the
% original array.
%    out=char2cellstr(in)
%
% See also SMASH.General
%


%
%
%
function out=char2cellstr(in)

% manage input

% identify new lines
start=1;
try
    stop=find(in == newline);
catch
    stop=find(in == sprintf('\n')); %#ok<SPRINTFN>
end

if stop(end) ~= numel(in)
    stop(end+1)=numel(in);
end

out=cell(size(stop));
for n=1:numel(stop)
    out{n}=in(start:stop(n)-1);
    start=stop(n)+1;
end

end