% PROBE Probe the file associated with a DigitizerFile object
%
% Syntax:
%    >> output=probe(object);
% The output is a structure with the following fields.
%    -NumberSignals
%    -Name ('agilent' format only)
%
% See also DigitizerFile, read
%

%
function varargout=probe(object)

% error checking
assert(exist(object.FullName,'file')==2,...
    'ERROR: cannot probe file because it does not exist');

% look inside source file
switch object.Format
    case 'acqiris'
        report=probe_acqiris(object.FullName);  
    case {'agilent','keysight'}
        report=probe_agilent(object.FullName);               
    case {'zdas','saturn'}
        file_id = hdfh('open',object.FullName,'read',0);
        status = hdfv('start',file_id); %#ok<NASGU>
        if file_id == -1
            status = hdfv('end',file_id); %#ok<NASGU>
            status = hdfh('close',file_id); %#ok<NASGU>
            hdfml('closeall');
            error('ERROR: File not found')
        elseif strcmpi(object.Format,'zdas')
            vgroup_ref = 4;
            vdata_ref = 9;
        elseif strcmp(object.Format,'saturn')
            vgroup_ref = 6;
            vdata_ref = 7;
        end
        vgroup_id = hdfv('attach',file_id,vgroup_ref,'r');
        count = hdfv('ntagrefs',vgroup_id);
        ndatasets = count/8;
        for i=0:ndatasets-1
            vdata_id = hdfvs('attach',file_id,vdata_ref+8*i,'r');
            n = hdfvs('elts',vdata_id);
            status = hdfvs('setfields',vdata_id,'NAME'); %#ok<NASGU>
            [name,count] = hdfvs('read',vdata_id,n);  %#ok<ASGLU>
            names(i+1,1:length(name{1})) = name{1};  %#ok<*AGROW>
        end
        hdfv('end',file_id);
        status = hdfh('close',file_id); %#ok<NASGU>
        hdfml('closeall');
        report.Names = char(sortrows(names));
        report.NumberSignals=size(report.Names,1);
    otherwise
        report.NumberSignals=1;
end

% handle output
if nargout==0
    disp(report);
else
    varargout{1}=report;
end

end