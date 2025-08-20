function report=probe_agilent(filename)

[~,~,ext]=fileparts(filename);

switch lower(ext)
    case '.h5'
        report=probe_agilentH5(filename);
    case '.bin'
        report=probe_agilentBIN(filename);
    otherwise
        error('ERROR: invalid file extension');
end

end

%%
function report=probe_agilentH5(filename)

NumWaveforms=h5readatt(filename,'/Waveforms','NumWaveforms');
report.Name=cell(1,NumWaveforms);
report.GroupName=report.Name;
report.DatasetName=report.Name;

info=h5info(filename,'/Waveforms');
NumGroups=numel(info.Groups);
if NumGroups==NumWaveforms
    for n=1:NumGroups
        report.Name{n}=info.Groups(n).Datasets.Name;
        report.GroupName{n}=info.Groups(n).Name;
        report.DatasetName{n}=fullfile(...
            info.Groups(n).Name,info.Groups(n).Datasets(1).Name);
        report.DatasetName{n}=strrep(report.DatasetName{n},'\','/'); % Windows fix
    end
else
    info=info.Groups;
    NumDatasets=numel(info.Datasets);
    assert(NumDatasets==NumWaveforms,...
        'ERROR: inconsistent number of waveforms/datasets');
    for n=1:NumDatasets
        report.Name{n}=info.Datasets(n).Name;
        report.GroupName{n}=info.Name;
        report.DatasetName{n}=fullfile(info.Name,info.Datasets(n).Name);
        report.DatasetName{n}=strrep(report.DatasetName{n},'\','/'); % Windows fix
    end
end
report.NumberSignals=NumWaveforms;
end

%%
function report=probe_agilentBIN(filename)

fid=fopen(filename,'r','ieee-le');
finishup = onCleanup(@() fclose(fid));
report.NumberSignals=0;
report.Name={};
report.IndexTable=[];

% file header
report.Cookie=char(transpose(fread(fid,2,'char')));
assert(strcmp(report.Cookie,'AG'),'ERROR: invalid file format');
report.Version=char(transpose(fread(fid,2,'char')));
report.FileSize=fread(fid,1,'uint32');
report.NumWaveforms=fread(fid,1,'uint32');

% sweep through waveforms
for m=1:report.NumWaveforms    
    % waveform header
    report.Waveform(m).HeaderSize=fread(fid,1,'uint32');
    report.Waveform(m).WaveformType=fread(fid,1,'uint32');  
    report.Waveform(m).NumBuffers=fread(fid,1,'uint32');
    report.Waveform(m).Points=fread(fid,1,'uint32');
    report.Waveform(m).Count=fread(fid,1,'uint32');
    report.Waveform(m).XDisplayRange=fread(fid,1,'single');
    report.Waveform(m).XDisplayOrigin=fread(fid,1,'double');
    report.Waveform(m).XIncrement=fread(fid,1,'double');
    report.Waveform(m).XOrigin=fread(fid,1,'double');
    report.Waveform(m).XUnits=assignUnits(fread(fid,1,'uint32'));   
    report.Waveform(m).YUnits=assignUnits(fread(fid,1,'uint32'));
    report.Waveform(m).Date=char(transpose(fread(fid,16,'char')));
    report.Waveform(m).Time=char(transpose(fread(fid,16,'char')));
    report.Waveform(m).Frame=char(transpose(fread(fid,24,'char')));
    report.Waveform(m).WaveformLabel=char(transpose(fread(fid,16,'char')));
    report.Waveform(m).TimeTags=fread(fid,1,'double');
    report.Waveform(m).SegmentIndex=fread(fid,1,'uint32');
    % waveform data header
    for n=1:report.Waveform(m).NumBuffers
        report.NumberSignals=report.NumberSignals+1;
        temp=deblank(report.Waveform(m).WaveformLabel);
        if report.Waveform(m).NumBuffers==1
            report.Name{end+1}=temp;
        else
            report.Name{end+1}=sprintf('%s-%d',temp,n);
        end
        report.IndexTable(end+1,:)=[report.NumberSignals m n];
        report.Waveform(m).Dataset(n).HeaderSize=fread(fid,1,'uint32');
        report.Waveform(m).Dataset(n).BufferType=fread(fid,1,'uint16');
        report.Waveform(m).Dataset(n).BytesPerPoint=fread(fid,1,'uint16');
        report.Waveform(m).Dataset(n).BufferSize=fread(fid,1,'uint32');
        report.Waveform(m).Dataset(n).Start=ftell(fid);
        fseek(fid,report.Waveform(m).Dataset(n).BufferSize,'cof');
    end
    
end

    function units=assignUnits(value)
        switch value
            case 0
                units='Unknown';
            case 1
                units='Volts';
            case 2
                units='Seconds';
            case 3
                units='Constant';
            case 4
                units='Amps';
            case 5 
                units='dB';
            case 6
                units='Hz';
        end        
    end

end