function [format, width] = formatG(sigfigs)
% FORMATG   Returns a format string using %g compatible with
%           a column containing N significant figures
% format = formatG(3) returns
% created 8/5/2004 by Daniel Dolan

if nargin < 1
    sigfigs = [];
end
if isempty(sigfigs)
    sigfigs = 3;
end

% Characters needed to display signs, decimal point, and zeros
minwidth = 7;
space = 1; % extra space to ensure column separation
width = sigfigs + minwidth + space;

format = ['%' num2str(width) '.' num2str(sigfigs) 'g'];