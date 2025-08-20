function [distance,direction]=arclength(x,y)

dx=diff(x(:));
dy=diff(y(:));
direction=[mean(dx) mean(dy)];

dx=[0; dx];
dy=[0; dy];
distance=cumsum(sqrt(dx.^2+dy.^2));
distance=reshape(distance,size(x));

end