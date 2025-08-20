function WriteIntegerArray(fid,array)

WriteLong(fid,numel(array));
WriteWord(fid,array);

end