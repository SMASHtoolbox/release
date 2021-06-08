function readDatasetHeader(fid)

fprintf('start: %d\n',ReadWord(fid));
fprintf('LDS: %d\n',ReadLong(fid));
fprintf('TRAW: %d\n',ReadWord(fid));
fprintf('VDS: %d\n',ReadWord(fid));
fprintf('TAPP: %d\n',ReadWord(fid));
fprintf('RFU: ')
fprintf('%d ',ReadWord(fid,10));
fprintf('\n');
fprintf('TYPE: %s\n',ReadString(fid));
fprintf('TITLE: %s\n',ReadString(fid)');

end