function data=readPFTVTX(fid)

data=struct('Format','pff','PFFdataset','PFTVTX');
data.VertexDim=ReadWord(fid);
data.AttributeDim=ReadWord(fid);
data.NumVertices=ReadLong(fid);
ReadWord(fid,5); % skip ISPARE
data.VertexLabel=cell(data.VertexDim,1);
for m=1:data.VertexDim
    data.VertexLabel{m}=ReadString(fid);
end
data.AttributeLabel=cell(data.AttributeDim,1);
for n=1:data.AttributeDim
    data.AttributeLabel{n}=ReadString(fid);
end
if (VDS==-3) && (data.VertexDim>0)
    data.VertexList=ReadFloatArray(fid);
    data.VertexList=reshape(data.VertexList,...
        [data.VertexDim data.NumVertices]);
elseif VDS==1
    data.VertexList=ReadFloatArray(fid);
end
data.AttributeList=ReadFloatArray(fid);

end