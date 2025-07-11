function result=ReadWord(fid,number)

if (nargin<2) || isempty(number)
    number=1;
end
result=fread(fid,number,'int16');

end