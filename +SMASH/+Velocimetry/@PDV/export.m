% export Export history data to a text file
%
% This method exports history data to a text file.
%    export(object,file); % specified file name
%    export(object); % interactive file name selection
%
% Standard export file files begin with a text header describing the
% object--source files, partition settings, etc.--followed by four-column
% blocks.  Each block is the history (time, velocity, uncertainty, and
% amplitude) for one region of interest; multi-channel results are combined
% by weighted averaging within each block.
%
% When the ExportMode property is 'compact', export files contain two
% numeric columns--time and velocity--with no text header.  Multiple
% regions of interest are written to separate files with a common base
% name.
%
% See also PDV, generateHistory
%

%
% created February 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function export(object,file)

switch object.Status.History
    case 'complete'
        % keep going
    case 'incomplete'
        error('ERROR: history data is incomplete');
    case 'obsolete'
        warning('PDV:obsolete','History data is obsolete');
end

% manage input
if (nargin < 2) || isempty(file)
    [fname,pname]=uiputfile('*.*','Select export file');
    if isnumeric(fname)
        return
    end
    file=fullfile(pname,fname);
else
    errmsg='ERROR: invalid file name';
    assert(ischar(file),errmsg);
end

% open file
%fid=1; % standard output
if strcmpi(object.ExportMode,'standard')
    fid=fopen(file,'w');
    CU=onCleanup(@() fclose(fid));
    
    % print header
    fprintf(fid,'"%s" exported (%s)\n',object.Name,datestr(now));
    fprintf(fid,'Comments: %s\n',object.Comments);
    fprintf(fid,'\n');
    
    fprintf(fid,'Data channels:\n');
    for n=1:object.NumberChannels
        fprintf(fid,'   %s\n',object.Channel{n}.Measurement.Source);
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'History settings:\n');
    header=SMASH.General.dumpStructure(object.HistorySettings);
    fprintf(fid,'   %s\n',header{:});
    fprintf(fid,'\n');
    
    % print blocks
    for n=1:object.NumberHistories
        fprintf(fid,'%s history:\n',object.History{n}.Name);
        fprintf(fid,'%15s %15s %15s %15s\n',...
            'Time','Velocity','Uncertainty','Amplitude');
        table=[object.History{n}.Grid object.History{n}.Data];
        fprintf(fid,'%#+15.6g %#+15.6g %#+15.2g %#+15.3g\n',transpose(table));
    end
elseif strcmpi(object.ExportMode,'compact')
   for n=1:object.NumberHistories
       if object.NumberHistories == 1
           name=file;
       else
           [pname,fname,ext]=fileparts(file);
           fname=sprintf('%s_region%.2d',fname,n);
           name=fullfile(pname,[fname ext]);
       end
       fid=fopen(name,'w');
       table=[object.History{n}.Grid object.History{n}.Data(:,1)];
       fprintf(fid,'%#+15.6g %#+15.6g\n',transpose(table));
       fclose(fid);
   end
end

end