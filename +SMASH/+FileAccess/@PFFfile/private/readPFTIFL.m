function data=readPFTIFL(fid)

data=struct('Format','pff','PFFdataset','PFTIFL');
data.FloatFlag=ReadWord(fid);
data.FloatListLength=ReadLong(fid);
data.IntegerArray=ReadIntegerArray(fid);
data.FloatList=nan(data.FloatListLength,1);
for n=1:data.FloatListLength
    data.FloatList(n)=ReadFloat(fid);
end
if data.FloatFlag~=0
    data.FloatArray=ReadFloatArray(fid);
end

end