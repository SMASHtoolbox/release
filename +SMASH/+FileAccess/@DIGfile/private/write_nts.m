function info=write_nts(signal,time,filename,info)

% handle function input(s)
if (nargin<1) || isempty(signal)
    error('ERROR: signal input required');
end
signal=signal(:); % force signal into column array
Ndata=numel(signal);

if (nargin<2) || isempty(time)
    time=0:(Ndata-1);
elseif numel(time)==1
    dT=time;
    time=0:dT:((Ndata-1)*dT);
end

if (nargin<3) || isempty(filename)
    [fname,pname]=uiputfile(...
        {'*.dig;*.DIG','DIG files'},...
        'Specify DIG file name');
    filename=fullfile(pname,fname);
end

if (nargin<4)
    info=struct();
end

% update info structure as needed
info.filename=filename;
info.preamble=repmat('*',[1 512]);
info.user=repmat('#',[1 256]);

info.system=sprintf('MATLAB digwrite 1.0');
info.timestamp=sprintf('%s',datestr(now,'ddd mmm dd HH:MM:SS yyyy'));
info.record_size=numel(signal);

if ~isfield(info,'word_size') || isempty(info.word_size)
    info.word_size=8;
    %info.word_size=16;
end
switch info.word_size
    case 8
        precision='uint8';
    case 16
        precision='uint16';
    case 32
        precision='uint32';        
    case 64
        precision='uint64';
    otherwise
        error('ERROR: invalid word size (%d) specified',info.word_size);
end
Nlevel=pow2(info.word_size);
info.T1=time(1);
info.dT=(time(end)-time(1))/(info.record_size-1);

if ~isfield(info,'V0') || isempty(info.V0)
    info.V0=min(signal);
end

if ~isfield(info,'dV') || isempty(info.dV)
   info.dV=(max(signal)-info.V0)/(Nlevel-1);
   %info.dV=(max(signal)-info.V0)/(Nlevel);
end

try 
    % digitize the signal
    maxlevel=(Nlevel-1);
    signal=(signal-info.V0)/info.dV;
    signal=round(signal);
    signal(signal<0)=0;
    signal(signal>maxlevel)=maxlevel;    
    % create file with empty header
    fid=fopen(filename,'wb');
    fwrite(fid,zeros(1,1024),'uint8');
    frewind(fid);
    % write header
    fprintf(fid,'%s',info.preamble);
    fprintf(fid,'%s',info.user);
    fprintf(fid,'%s\n',info.system);
    fprintf(fid,'%s\n',info.timestamp);
    fprintf(fid,'%d\n',info.record_size);
    fprintf(fid,'%d\n',info.word_size);
    fprintf(fid,'%+.6e\n',info.dT);
    fprintf(fid,'%+.6e\n',info.T1);
    fprintf(fid,'%+.6e\n',info.dV);
    fprintf(fid,'%+.6e\n',info.V0);
    % write data
    fseek(fid,1024,'bof');
    fwrite(fid,signal,precision);
catch
    fprintf('File write not successful\n');
    info=[];
end
fclose(fid);