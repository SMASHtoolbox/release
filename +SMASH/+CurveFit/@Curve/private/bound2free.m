function u=bound2free(x,left,right)

if left==right
    u=left;
elseif isinf(left) && isinf(right)
    u=x;
elseif isinf(left)     
    u=sqrt(right-x);
elseif isinf(right)   
    u=sqrt(left-x);
else
    u=nan(size(x));
    param=[0.1875 0 -0.625 -0 0.9375 0.5];
    temp=zeros(size(param));
    for k=1:numel(x)
        if (x<left) || (x>right)
            continue
        end
        temp(end)=(x(k)-left)/(right-left);
        solution=roots(param-temp);
        A=real(solution);
        keep=(A>=-1) & (A<=1);
        solution=solution(keep);
        [~,index]=min(abs(imag(solution)));
        u=solution(index);
    end          
end

end