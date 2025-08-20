% export Export result to file
%
% This method exports results to a text file.
%    export(object);      % interactive file selection
%    export(object,file); % manual file selection
% By default, the most recent reduction is exported to selected/specified
% file.  Optional name/value pairs:
%    export(object,file,name,value,...); % use file='' for interactive file selection
% can be passed to control which result is exported.  Valid options
% include:
%    -'Result', which must be 'reduction' (default) or 'preview'.
%    -'Index', which must be an integer.  The most recent result index is 0
%    (default).  Offsets from the most recent result are specified by
%    negative numbers, e.g. -1 is the second most recent result.
%    Postive numbers indicate the absolute index, e.g. +2 is the second
%    result.
% An error is generated when the requested result is not available.
%
% Object arrays can be exported simultaneously.  The base file name
% is selected/specified as above, with index numbers appended to each
% export file.  Options work in a similar manner, though an array of index
% values (consistent with the number of object elements) can be specified.
% Scalar index values are implicitly matched to each object element
%
%
% See also SFR, setName, reduce, preview
%
function export(object,file,varargin)

%assert(isscalar(object),'ERROR: cannot export from object array');

% manage options
option=struct('Type','reduction','Index',0);
option=SMASH.Developer.options2struct(option,varargin{:});

assert(ischar(option.Type),...
    'ERROR: export type must be ''reduction'' or ''preview''');
option.Type=lower(option.Type);

assert(isnumeric(option.Index),'ERROR: index must be numeric');
if isscalar(option.Index)
    option.Index=repmat(option.Index,size(object));
else
    assert(numel(option.Index) == numel(object),...
        'ERROR: index and object array are not consistent');
end

% manage file name
if (nargin < 2) || isempty(file)
    [file,location]=uiputfile({'*.txt' 'Text files'},...
        'Select export file');
    if isnumeric(file)
        return
    end
    file=fullfile(location,file);
else
    if isstring(file)
        file=char(file(1));
    end
    assert(ischar(file),'ERROR: invalid export file');
end
[location,base,ext]=fileparts(file);

% export result
N=numel(object);
target=file;
for n=1:N
    if N > 1
        target=sprintf('%s-%d',base,n);
        target=fullfile(location,[target ext]);
    end
    try
        fid=fopen(target,'w');
    catch
        error('ERROR: unable to create requested export file');
    end
    try
        result=getResult(object(n),option.Type,option.Index(n));
    catch 
        error('ERROR: no %s available for element %d',...
            option.Type,option.Index(n));
    end
    data=result.Data;
    result=rmfield(result,'Data');
    T=1/result.SampleRate;
    for row=1:size(data,1)
        time=SMASH.General.sigprint(data(row,1),T,...
            'Digits',2,'Convention','flexible','ForceSign',true);
        [value,uncertainty]=SMASH.General.sigprint(data(row,2),data(row,3),...
            'Digits',2,'Convention','flexible','ForceSign',false);
        quality=sprintf('%#.3g',data(row,4));
        fprintf(fid,'%s %s %s %s\n',time,value,uncertainty,quality);
    end
    fprintf(fid,'SFR export file\n');
    if strcmp(option.Type,'preview')
        fprintf(fid,'Preview for "%s"\n',object(n).Name);
        fprintf(fid,'Columns are [time frequency width quality]\n');
        writeUnits();
        writeParameters();
    else
        fprintf(fid,'Reduction for "%s"\n',object(n).Name);
        fprintf(fid,'Columns are [time frequency uncertainty quality]\n');
        writeUnits()
        writeParameters();
        M=numel(result.Selection);
        if M == 0
            fprintf(fid,'No ROI selections\n');
            continue
        end
        fprintf(fid,'%d ROI selections\n',M);
        for m=1:M
            fprintf(fid,'Time Frequency Width\n');
            fprintf(fid,'%g %g %g\n',transpose(result.Selection(m).Data));
        end
    end
    fclose(fid);
end
    function writeUnits()
        if isempty(object.Units.Time)
            fprintf(fid,'Time units not specified\n');
        else
            fprintf(fid,'Time expressed in %s\n',object.Units.Time);
        end
        if isempty(object.Units.Frequency)
            fprintf(fid,'Frequency units not specified\n');
        else
            fprintf(fid,'Frequency expressed in %s\n',object.Units.Frequency);
        end
        fprintf(fid,'Quality ratio expressed in dB\n');
    end
    function writeParameters()
        name=fieldnames(result);
        for kk=1:numel(name)
            value=result.(name{kk});
            if ischar(value)
                fprintf(fid,'%s: %s\n',name{kk},value);
            elseif strcmpi(name{kk},'Window')
                fprintf(fid,'Window.Name: %s\n',value.Name);
                fprintf(fid,'Window.Parameter: %g\n',value.Parameter);
            elseif contains(name{kk},'Time')
                value=SMASH.General.sigprint(value,T,...
                    'Digits',2,'Convention','flexible');
                fprintf(fid,'%s: %s\n',name{kk},value);
            elseif strcmp(name{kk},'Selection')
                continue
            elseif isstruct(value)
                if isfield(value,'Plot')
                    value=rmfield(value,'Plot');
                end
                info=SMASH.General.structure2list(value);
                format=sprintf('%s.%%s: %%g\\n',name{kk});
                fprintf(fid,format,info{:});
            else
                fprintf(fid,'%s: %g\n',name{kk},value);
            end
        end
    end
end