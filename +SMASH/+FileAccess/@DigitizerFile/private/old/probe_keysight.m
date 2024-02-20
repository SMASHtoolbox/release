function report=probe_keysight(filename)

[~,~,ext]=fileparts(filename);
assert(strcmpi(ext,'.h5'),'ERROR: invalid file extension');

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
    end
end
report.NumberSignals=NumWaveforms;

end