function data=readPFTNG3(fid)

NBLKS=ReadWord(fid);
data=struct('Format','pff','PFFdataset','PFTNG3');
for block=1:NBLKS
    NX=ReadLong(fid); %#ok<NASGU>
    NY=ReadLong(fid); %#ok<NASGU>
    NZ=ReadLong(fid); %#ok<NASGU>
    ReadIntegerArray(fid); % spare entry
    temp.X=ReadFloatArray(fid);
    temp.Y=ReadFloatArray(fid);
    temp.Z=ReadFloatArray(fid);
    temp.XLabel=ReadString(fid);
    temp.YLabel=ReadString(fid);
    temp.ZLabel=ReadString(fid);
    temp.BLabel=ReadString(fid);
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