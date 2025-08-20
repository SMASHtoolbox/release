function WriteLong(fid,number)

persistent imsk
if isempty(imsk)
    imsk=[pow2(14) pow2(15) pow2(15)];
end

%number=int16(number);
array=[0 0 0];
remainder=abs(number);
for k=3:-1:1
    if remainder >= imsk(k)
        temp=floor(remainder/imsk(k));
        array(k)=remainder-imsk(k)*temp;
        remainder=temp;
    else
        array(k)=remainder;
        remainder=0;
    end
end
assert(remainder==0,'ERROR: long value out of range');

if number<0
    array(1)=array(1)+imsk(1);
end

fwrite(fid,array,'int16');

end