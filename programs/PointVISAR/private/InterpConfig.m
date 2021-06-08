% InterpConfig : interpret a configuration file

% created 1/22/2007 by Daniel Dolan
function [data,status]=InterpConfig(data,filename)

status.exitmode='normal';
status.message='';
pathname=fileparts(filename);

numrecords=numel(data);
for ii=1:numrecords
    name=fieldnames(data{ii}); % store specified fields
    record=CreateRecord(data{ii}.Type); % create default record
    name0=record.ParameterFields;
    numfields=numel(name0);    
    for jj=1:numfields % sweep through specifiable fields
        % locate field name in record
        if isfield(data{ii},name0{jj}) % interpret configuration value
            value0=record.(name0{jj});
            value=data{ii}.(name0{jj});
            if isnumeric(value0)
                value=sscanf(value,'%g');
                if isempty(value)
                    value=value0;
                end
            elseif islogical(value0)
                value=logical(sscanf(value,'%g'));
            else
                switch name0{jj}
                    case 'Notes'
                        value=NotesScanner(value);                       
                    case 'InputFiles'
                        [value,status]=FilenameScanner(value,pathname);
                    case 'OutputFile'
                        [value,status]=FilenameScanner(value,pathname);
                        %if isempty(value)
                        %    % do nothing
                        %else
                        %    value=value{1};
                        %end
                    otherwise
                        value=sscanf(value,'%c');
                end
            end
            record.(name0{jj})=value;
        end
        % remove field name from list
        for kk=1:numel(name)
            if strcmp(name{kk},name0{jj})
                name(kk)=[];
                break
            end
        end
    end
    % warn user about unused fields
    for kk=1:numel(name)
        fprintf('Unrecognized field "%s" ignored\n',name{kk});
        data{ii}=rmfield(data{ii},name{kk});
    end
    data{ii}=record; % store interpreted record
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=NotesScanner(array)

array=strtrim(array);
stop=strfind(array,sprintf('\n'));
start=[1 (stop+1)];
stop=[(stop-1) numel(array)];
N=numel(start);
func=cell(1,N);
for kk=1:N
    func{kk}=strtrim(array(start(kk):stop(kk)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [filename,status]=FilenameScanner(array,pathname)

filename={};
status.exitmode='normal';
status.message='';
olddir=pwd;

done=false;
while ~done  
    % try to read file name
    [fname,count,errmsg,next]=sscanf(array,'%s',1);
    % handle empty field
    if isempty(fname) 
        done=true;
        continue
    end
    % handle quotes
    quotes=strfind(fname,'''');
    switch numel(quotes)
        case 0 % space free scan
            % nothing needs to be done
        case 1 % space(s) in file name
            quotes=strfind(array,'''');
            if numel(quotes)<2
                status.exitmode='error';
                status.message=...
                    sprintf('Unmatched quotes in file name: %s',fname);
                fprintf('%s\n',status.message);
                return
            end
            fname=array(quotes(1):quotes(2));
            fname=fname(2:end-1);
            next=quotes(2)+1;
        case 2 % space free scan with matching quotes
            fname=fname(2:end-1);
        otherwise
            status.exitmode='error';
            status.message=sprintf('Too many quotes in file name: %s',fname);
            fprinf('%s\n',status.message);
            return
    end
    % replace inappropriate slashes
    fname((fname=='\') | (fname=='/'))=filesep;    
    % convert to absolute file name
    cd(pathname);
    [local,fname,ext]=fileparts(fname);
    if isempty(local)
        local=olddir;
    end
    try
        cd(local);
        filename{end+1}=fullfile(pwd,[fname ext]);
    catch
        cd(olddir);
        status.exitmode='error';
        status.message=...
            sprintf('Invalid directory specified: %s',...
            fullfile(pathname,local));
        fprintf('%s\n',status.message);
        return
    end
    array=array(next:end);
end

cd(olddir);
