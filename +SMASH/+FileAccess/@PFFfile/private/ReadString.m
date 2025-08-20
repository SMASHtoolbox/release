function result=ReadString(fid)

Nword=ReadWord(fid);
if Nword==0
    result='';
else
    result=fread(fid,2*Nword,'uchar');
    result=reshape(result,1,numel(result));
    result=char(result);
end

end