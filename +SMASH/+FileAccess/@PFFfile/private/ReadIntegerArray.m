function result=ReadIntegerArray(fid)

LENGTH=ReadLong(fid);
result=ReadWord(fid,LENGTH);

end