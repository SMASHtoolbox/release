%   SaveConfig  Save current PointVISAR configuration to file.
%               Writes out necessary values from UserData to a file so that
%               the user can reproduce the same analysis or a similar 
%               one at a later time.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function message=SaveConfig(data)

% Prompt the user for a configuration filename
suggestion = 'AnalysisConfig.txt';
dialogtitle = 'Save configuration ';
[fname,pname] = putfilename({'*.*','All files'},dialogtitle,suggestion);
if isnumeric(fname) % user presed cancel or killed dialog
    return
end
filename=[pname fname];
rootpath=pname;

% Open the specified file and begin generating the file text
fid=fopen(filename,'wt');
message{1} = '% VISAR Analysis configuration';
message{2} = ['% Generated ' datestr(now) ' by PointVISAR version ' PointVISARversion];
message{3} = '';
offset=repmat(' ',[1 3]);

% For each data record
for ii=1:length(data);
    names=data{ii}.ParameterFields;    
    
    % Begin tag
    message{end+1} = ['begin{' data{ii}.Type '}'];
    
    % All other parameters
    for jj=2:numel(names)
        field=names{jj};
        value=data{ii}.(field);
                     
        if isnumeric(value) || islogical(value)
            numbers='';
            for kk=1:numel(value)
                numbers=[numbers EditBoxNum2Str(value(kk)) ' '];
            end
            message{end+1} = [offset field ' = {' numbers(1:end-1) '}'];
        elseif ischar(value)
            message{end+1}=[offset field ' = {' value '}'];
        elseif iscell(value)
             % convert absolute paths to relative paths
            if strcmp(field,'InputFiles')
                for kk=1:numel(value)
                    [pathname,filename,extension]=fileparts(value{kk});
                    pathname=RelativePath(pathname,rootpath);
                    filename=[filename extension];
                    value{kk}=['''' fullfile(pathname,filename) ''''];
                end
            end
            if strcmp(field, 'OutputFile')
                for kk=1:numel(value)
                    if isempty(value{kk})
                        filename='';
                    else
                        [pathname,filename,extension]=fileparts(value{kk});
                        pathname=RelativePath(pathname,rootpath);
                        filename=[filename extension];
                        value{kk}=['''' fullfile(pathname,filename) ''''];
                    end
                end
            end
            message{end+1}=[offset field ' ='];
            message{end+1}=[offset '{'];
            for kk=1:numel(value)
                message{end+1}=[offset offset value{kk}];
            end
            message{end+1}=[offset '}'];
        end
    end
    
    % Add the end tag for this record data
    %message{end+1} = 'end';
    message{end+1}=['end{' data{ii}.Type '}'];
    message{end+1} = '';
end

% Write the entire message to the file
fprintf(fid,'%s\n',message{:});

% Close the configuration file
fclose(fid);