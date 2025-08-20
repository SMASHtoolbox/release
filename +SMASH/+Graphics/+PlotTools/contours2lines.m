% contours2lines Extract line data from contour matrix
%
% This function extracts line data from a contour matrix (as generated from
% contourc).
%    [data,level]=contours2lines(Cmatrix)
% The output "data" is a cell array containing two-column numeric arrays
% ([x y]).  The output "level" is a corresponding array of contour levels
% for each (x,y) data set.
%
% See also Graphics, plotContourMatrix, contourc
%


function [data,level]=contours2lines(Cmatrix)

% manage input
assert(nargin==1,'ERROR: invalid number of inputs');
assert(size(Cmatrix,1)==2,'ERROR: invalid contour matrix');

% process contour matrix
level=[];
data={};

start=1;
while start<size(Cmatrix,2)
    % extract contour
    level(end+1)=Cmatrix(1,start); %#ok<AGROW>
    M=Cmatrix(2,start);
    start=start+1;
    stop=start+M-1;
    data{end+1}=transpose(Cmatrix(:,start:stop));     %#ok<AGROW>
    % prepare for next contour
    start=stop+1;
end

end