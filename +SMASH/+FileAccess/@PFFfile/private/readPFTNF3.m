function data=readPFTNF3(fid)

NBLKS=ReadWord(fid);
data=struct('Format','pff','PFFdataset','PFTNF3');
for block=1:NBLKS
    % read data
    NX=ReadLong(fid);
    NY=ReadLong(fid);
    NZ=ReadLong(fid);
    ReadWord(fid,5); % skip ISPARE
    temp.X=ReadFloatArray(fid);
    temp.X=reshape(temp.X,[1 NX]);
    temp.Y=ReadFloatArray(fid);
    temp.Y=reshape(temp.Y,[1 NY]);
    temp.Z=ReadFloatArray(fid);
    temp.Z=reshape(temp.Z,[1 NZ]);
    temp.XLabel=ReadString(fid);
    temp.YLabel=ReadString(fid);
    temp.ZLabel=ReadString(fid);
    temp.BLabel=ReadString(fid);
    temp.Data=ReadFloatArray(fid);
    temp.Data=reshape(temp.Data,[NY NX NZ]);
    % manage blocks
    name=fieldnames(temp);
    for k=1:numel(name)
        if NBLKS==1
            data.(name{k})=temp.(name{k});
        else
            data.(name{k}){block}=temp.(name{k});
        end
    end
end

end