function data=export_signals(data)

% determine output file
if ~isfield(data,'outputfile') || isempty(data.outputfile)
    filespec={'*.*','All files'};
    [filename,pathname]=uiputfile(filespec,'Select output file');
    data.outputfile=fullfile(pathname,filename);
end
fid=fopen(data.outputfile,'wt');

% write header
params=data.params;
fprintf(fid,'%s data generated %s using input file:\n',upper(data.mode),datestr(now));
[pname,filename,ext]=fileparts(data.inputfile);
filename=[filename ext];
fprintf(fid,'\t%s\n',filename);
fprintf(fid,'and the following parameters.\n');
name=fieldnames(params);
value=struct2cell(params);
width=max(cellfun(@length,name));
name_format=sprintf('%%%ds: ',width+5);
for n=1:numel(name)
    % omit unused fields    
    if strcmp(data.mode,'VISAR')
        if strcmp(name{n},'ref_scale')
            continue
        end
    elseif strcmp(data.mode,'PDV')
        if strcmp(name{n},'delay') || strcmp(name{n},'dispersion')
            continue
        end
        if strcmp(name{n},'delay_scale')
            continue
        end
    end
    % print valid fields
    fprintf(fid,name_format,name{n});
    if strcmp(name{n},'impulse_response')
        [pname,fname,ext]=fileparts(value{n});
        filename=[fname ext];
        fprintf(fid,'%s ',filename);
    elseif strcmp(name{n},'coupling')
        fprintf(fid,'%15s',value{n});        
    else
        fprintf(fid,'%15.5g',value{n});
    end
    %switch name{n}
    %    case 'coupling'
    %        value_format='%15s';
    %    case 'impulse_response'
    %    otherwise
    %        value_format='%15.5g ';
    %end
    %fprintf(fid,value_format,value{n});
    fprintf(fid,'\n');
end

% write signal data
Nsignal=numel(data.signal);
temp=zeros(numel(data.time),Nsignal+1);
temp(:,1)=data.time;
fprintf(fid,'%15s','Time');
for k=1:Nsignal
    temp(:,k+1)=data.signal{k};    
    label=sprintf('Signal %d',k);
    fprintf(fid,'%15s',label);
end
fprintf(fid,'\n');
format=repmat('%+15.5e',[1 Nsignal+1]);
format=[format '\n'];
fprintf(fid,format,transpose(temp));

fclose(fid);