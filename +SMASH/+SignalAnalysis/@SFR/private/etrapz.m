% utrapz Evenly-spaced trapezoid integration
function area=etrapz(y,bound)

intervals=numel(y)-1;
area=y(1)+2*sum(y(2:end-1))+y(end);
area=(bound(2)-bound(1))/(2*intervals)*area;

end