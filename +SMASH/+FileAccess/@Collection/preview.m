% preview Show collection files
%
% This method shows files consistent with the Location, Pattern, and Format
% properties of a collection.
%    preview(object); % prints list in the command window
%    report=preview(object); % returns a structure array
% Previews include the format and record labels (if any) that would be
% used to read data from each matching file.
%
% See also Collection, read
%
function varargout=preview(object)

% manage object arrays
N=numel(object);
if N > 1
    for n=1:N
        if nargout == 0
            preview(object(n));
        elseif n == 1
            report=preview(object(n));
        else
            report=[report preview(object(n))]; %#ok<AGROW> 
        end
    end
    if nargout > 0
        varargout{1}=report;
    end
    return
end

% scalar object
target=fullfile(object.Location,object.Pattern);
source=dir(target);
Nfile=numel(source);
%assert(Nfile > 0,'ERROR: no file match found')

Nformat=numel(object.Format);
Nrecord=numel(object.Record);

report=[];
    function appendReport(value)
        if isempty(report)
            report=value;
        else
            report(end+1)=value;
        end
        [~,file,ext]=fileparts(value.File);
        summary=sprintf('''%s'' using ''%s'' format',...
            [file ext],value.Format);       
        if isempty(value.Record)
            % do nothing
        elseif isnumeric(value.Record)
            summary=sprintf('%s (record %g)',summary,value.Record);
        else
            summary=sprintf('%s (record ''%s'')',summary,value.Record);
        end        
        report(end).Summary=summary;
    end

for k=1:Nfile
    temp=fullfile(source(k).folder,source(k).name);
    for m=1:Nformat        
        format=object.Format{m};
        try
            [~]=SMASH.FileAccess.probeFile(temp,format);
        catch
            continue
        end
        % read data
        new=struct('File',temp,'Format',format,'Record',[],'Summary','');
        if Nrecord == 0
            appendReport(new);
            continue
        end
        for n=1:Nrecord
            new.Record=object.Record{n};
            appendReport(new);
        end
    end

end

% manage output
if nargout == 0
    fprintf('Files to be read from %s\n',object.Location)
    if isempty(report)
        fprintf('   (no matches)\n');
    end
    for k=1:numel(report)
        fprintf('   %s\n',report(k).Summary);
    end
else
    varargout{1}=report;
end

end