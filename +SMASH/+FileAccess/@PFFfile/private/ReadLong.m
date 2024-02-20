function result=ReadLong(fid,number)

if (nargin<2) || isempty(number)
    number=1;
end

result=nan(1,number);
for n=1:number
    word=fread(fid,3,'int16');
    M1=pow2(14);
    M2=pow2(15);
    M3=pow2(15);
    if word(1)<M1
        s=+1;
    else
        s=-1;
    end
    result(n)=s*((mod(word(1),M1)*M2+word(2))*M3+word(3));
end

end