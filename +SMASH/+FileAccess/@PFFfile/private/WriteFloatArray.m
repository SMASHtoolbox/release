function WriteFloatArray(fid,value)

WriteWord(fid,-6); % FP_FULL
WriteWord(fid,0); % foff10
WriteLong(fid,numel(value)); % LENGTH
fwrite(fid,value(:),'single'); 

end