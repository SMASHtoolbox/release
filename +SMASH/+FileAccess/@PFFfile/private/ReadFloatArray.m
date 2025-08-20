function result=ReadFloatArray(fid)


first=ReadWord(fid);
if first==-6 % full float precision
    FOFF10=ReadWord(fid); %#ok<NASGU>
    LENGTH=ReadLong(fid);
    result=fread(fid,LENGTH,'single');    
else % reduced float precision
    fseek(fid,-2,'cof');
    OFFSET=ReadFloat(fid);
    SCALE=ReadFloat(fid);
    LENGTH=ReadLong(fid);
    result=ReadWord(fid,LENGTH);
    result=OFFSET+SCALE*result;
end

end