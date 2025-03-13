function R=ParameterRatios(contrast,rootsign)

root=sqrt(1-contrast.^2);

ratio=ones(1,3);
for k=1:3
    if strcmp(rootsign(k),'+')
        ratio(k)=(1+root(k))/(1-root(k));
    else
        ratio(k)=(1-root(k))/(1+root(k));
    end
end

R(1)=sqrt(ratio(2)/ratio(1));
R(2)=sqrt(ratio(3)/ratio(1));