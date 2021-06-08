function format = formatS(width)
% FORMATS   Returns a format string using %s compatible with
%           a column that is N characters wide
% format = formatS(3) returns
% created 8/5/2004 by Daniel Dolan

if nargin < 1
    width = [];
end
if isempty(width)
    width = 3;
end

format = ['%' num2str(width) 's'];