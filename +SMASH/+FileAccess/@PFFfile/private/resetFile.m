function resetFile(fid)

%location=ftell(fid);
%frewind(fid);
%fseek(fid,location,'bof');
fseek(fid,0,'cof');

end