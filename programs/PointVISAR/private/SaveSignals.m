% Saves signals for a single VISAR record

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function record=SaveSignals(record)

% file admin
file=record.OutputFile{1};
[pname,file,ext]=fileparts(file);
file=[file ext];
drop=repmat(false,size(file));
forbidden={'?','*','|','"','''','=',',',';',':',...
    '(',')','<','>','[',']',};
for k=1:numel(forbidden)
    drop=drop | (file==forbidden{k});
end
if any(drop)
    fprintf('Invalid file name characters detected:\n');
    original=file;
    file(drop)='';
    fprintf('\t%s\n\tchanged to\n\t%s\n',original,file);
end
file=fullfile(pname,file);
record.OutputFile{1}=file;

%if exist(file)
%    delete(file);
%end

[fid,message]=fopen(file, 'wt');
if fid<0
    message{2}='Unable to open file';
    message=message([2 1]);
    error('%s\n',message{:});
end

% main header
label=record.Label;
header=['% PointVISAR calculations for ' label ' (generated ' datestr(now) ')'];
fprintf(fid, '%s\n', header);

% determine output mode
mode=record.OutputFileMode;
switch lower(mode)
    case 'compact'
        heading={'Time' 'Velocity'};
        data(1,:)=record.Time;
        data(2,:)=record.Velocity;      
    case 'full'
        heading={'Time' 'Velocity' 'Phase' 'BIM' 'Contrast' 'D1' 'D2'};
        data(1,:)=record.Time;
        data(2,:)=record.Velocity;
        data(3,:)=record.Phase;
        data(4,:)=record.BIM;
        data(5,:)=record.Contrast;
        data(6,:)=record.D{1};
        data(7,:)=record.D{2};
    otherwise
        error('Invalid output mode');
end

% run through data columns to determine proper formats and column header
sigfigs=7;
header='%';
numformat='';
for ii=1:numel(heading)
    [format,width]=SmartFormat(data(ii,:),sigfigs);
    textformat=['\t%' num2str(width,'%i') 's'];
    header=[header sprintf(textformat,heading{ii})];
    numformat=[numformat '\t' format];
end
numformat = [numformat '\n'];

% print column header and data
fprintf(fid,'%s\n',header);
fprintf(fid, numformat, data);
fclose(fid);
