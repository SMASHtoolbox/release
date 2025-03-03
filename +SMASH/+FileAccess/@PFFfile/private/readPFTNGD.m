function data=readPFTNGD(fid,VDS)

data=struct('Format','pff','PFFdataset','PFTNGD');
M=ReadWord(fid);
N=ReadWord(fid);
if VDS==1
    data.NX=ReadLong(fid,M);
else
    data.NX=ReadWord(fid,M);
end
data.NX=reshape(data.NX,[1 numel(data.NX)]);

ReadIntegerArray(fid); % spare entry

data.ALABEL=cell(1,M);
for m=1:M
    data.ALABEL{m}=ReadString(fid);
end
data.VLABEL=cell(1,N);
for n=1:N
    data.VLABEL{n}=ReadString(fid);
end

data.X=cell(1,M);
for m=1:M
    temp=ReadFloatArray(fid);
    temp=reshape(temp,[1 numel(temp)]);
    data.X{m}=temp;
end
data.Data=cell(N,1);

for n=1:N
    temp=ReadFloatArray(fid);
    if numel(data.NX)==1
        temp=reshape(temp,[1 data.NX]);
    else
        temp=reshape(temp,data.NX);
        index=1:numel(data.NX);
        index(1)=2;
        index(2)=1;
        temp=permute(temp,index);
    end
    data.Data{n}=temp;
end

end