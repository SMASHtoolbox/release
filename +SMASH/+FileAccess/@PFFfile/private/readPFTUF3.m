function data=readPFTUF3(fid)

data=struct('Format','pff','PFFdataset','PFTUF3');
NBLKS=ReadWord(fid);
for block=1:NBLKS
    % read data
    NX=ReadLong(fid);
    NY=ReadLong(fid);
    NZ=ReadLong(fid);
    ReadWord(fid,5); % skip ISPARE
    X0=ReadFloat(fid);
    DX=ReadFloat(fid);
    temp.X=X0+(0:(NX-1))*DX;
    Y0=ReadFloat(fid);
    DY=ReadFloat(fid);
    temp.Y=Y0+(0:(NY-1))*DY;
    Z0=ReadFloat(fid);
    DZ=ReadFloat(fid);
    temp.Z=Z0+(0:(NZ-1))*DZ;
    temp.XLabel=ReadString(fid);
    temp.YLabel=ReadString(fid);
    temp.DataLabel=ReadString(fid);
    temp.BLabel=ReadString(fid);
    temp.Data=ReadFloatArray(fid);
    temp.Data=reshape(temp.Data,[NX NY NZ]);
    temp.Data=permute(temp.Data,[2 1 3]);
    %temp.X=temp.X/1000; % convert um to mm
    %temp.Y=temp.Y/1000; % convert um to mm         
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