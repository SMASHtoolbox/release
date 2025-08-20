function [value,in]=readNumber(in,N)

if nargin < 2
    N=inf;
end

[value,~,~,next]=sscanf(in,'%g',[1 N]);
in=in(1:(next-1));

end