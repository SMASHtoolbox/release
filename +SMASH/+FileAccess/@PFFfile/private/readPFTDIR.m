function data=readPFTDIR(fid)

data=struct('Format','pff','PFFdataset','PFTDIR');
data.TRAW=ReadWord(fid);
data.Length=ReadLong(fid);
data.Location=ReadLong(fid);

end