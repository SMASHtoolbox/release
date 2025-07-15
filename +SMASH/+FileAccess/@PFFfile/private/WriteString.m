function WriteString(fid,value)

N=length(value);
if rem(N,2) == 1
    value=sprintf('%s ',value); % force even number of characters
end
N=length(value)/2; % string length in words

WriteWord(fid,N);
fwrite(fid,value,'uchar');

end