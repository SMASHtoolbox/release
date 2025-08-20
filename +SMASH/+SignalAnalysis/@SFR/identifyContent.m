% 
function flag=identifyContent(ratio,nhood,threshold)

N=numel(ratio);
keep=isfinite(ratio);
ratio(~keep)=0;
while true
    [value,k]=max(ratio);
    if value < threshold
        break
    end
    start=1;
    for m=k:-1:start
        if ratio(m) < threshold
            start=m+1;
            break
        end
    end
    stop=N;
    for m=k:stop
        if ratio(m) < threshold
            stop=m-1;
            break
        end
    end        
    drop=start:stop;
    if stop-start >= nhood
        keep(drop)=false;
    end
    ratio(drop)=0;    
end
flag=(~keep);

end