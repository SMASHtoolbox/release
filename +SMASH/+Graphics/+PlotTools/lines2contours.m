% lines2contours Convert line data to a contour matrix
%

function Cmatrix=lines2contours(data,level)

% manage output
N=numel(data);

if (nargin<2) || isempty(level)
    level=1:N;
end
assert(isnumeric(level) && numel(level)==N,...
    'ERROR: invalid level array');

% generate contour matrix
Cmatrix=zeros(2,0);
column=0;
for n=1:N
    temp=transpose(data{n});
    column=column+1;
    Cmatrix(1,column)=level(n);    
    Cmatrix(2,column)=size(temp,2);  
    Cmatrix=[Cmatrix temp]; %#ok<AGROW>
    column=size(Cmatrix,2);
end

end