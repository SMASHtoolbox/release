function result=ReadFloat(fid)

word=fread(fid,3,'int16');
%word=fread(fid,3,'uint16');
two15=pow2(15);
rtwo15=1/two15;

% revised approach
ie=floor(word(3)/2);
if ie==0
    result=0;
    return
end

is=word(3)-2*ie;
i2=ie-8192;
xsign=1-2*is;
i2m=i2-1;
twooff=pow2(i2m);

result=xsign*...
    (((word(2)*rtwo15+word(1))*rtwo15+1)*twooff);

% original approach
%result=(1-2*mod(word(3),2))*...
%    ((word(2)*rtwo15+word(1))*rtwo15+1)*...
%    2^(word(3)/2-8193);

end