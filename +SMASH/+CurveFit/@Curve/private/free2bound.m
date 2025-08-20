function x=free2bound(u,left,right)

if left==right
    x=left;
elseif isinf(left) && isinf(right)
    x=u;
elseif isinf(left) 
    x=right-u.^2;
elseif isinf(right)
    x=left+u.^2;
else
    x=zeros(size(u));
    x(u>1)=1;
    index=(u>=-1) & (u<=1);
    param=[0.1875 0 -0.625 -0 0.9375 0.5 ];
    x(index)=polyval(param,u(index));
    x=left+(right-left)*x;
end

end