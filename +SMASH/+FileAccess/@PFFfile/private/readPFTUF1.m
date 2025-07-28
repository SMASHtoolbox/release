function data=readPFTUF1(fid)

data=struct('Format','pff','PFFdataset','PFTUF1');
NBLKS=ReadWord(fid);
for block=1:NBLKS
    % read data
    NX=ReadLong(fid);
    ISPARE=ReadWord(fid,5); %#ok<NASGU>
    X0=ReadFloat(fid);
    DX=ReadFloat(fid);
    temp.X=X0+(0:(NX-1))*DX;
    temp.XLabel=ReadString(fid);
    temp.BLabel=ReadString(fid);
    temp.Data=ReadFloatArray(fid); 
    temp.Data=reshape(temp.Data,[1 NX]);
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