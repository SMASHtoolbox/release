% PointVISAR : VISAR analysis program
% 
% For more information, type PointVISAR -help

% created 4/11/2006 by Daniel Dolan
% last modified 1/24/2007 by Daniel Dolan
% last modified 4/24/2011 by Daniel Dolan

function varargout=PointVISAR(varargin)

% separate flags from file names
file={};
arg={};
for ii=1:nargin
    if strcmp(varargin{ii}(1),'-')
        arg{end+1}=varargin{ii}(2:end);
    else
        file{end+1}=varargin{ii};
    end
end

% interpret input flags
mode='gui'; % default 
for ii=1:numel(arg)
    switch lower(arg{ii})
        case {'batch','console','gui'}
            mode=arg{ii};
        case 'help'         
            CommandLineHelp;
            mode='help';
            break
        otherwise
            fprintf('\n Invalid flag entered! ');
            fprintf('Type ''PointVISAR -help'' for valid input options. \n\n');
    end
end

if strcmp(mode,'batch')
    mode='console';
end

if isempty(file) && strcmp(mode,'console')
    [filename,pathname]=uigetfile('*.*','Select configuration file');
    if isnumeric(filename) % user pressed cancel
        file=[];
    else
        file={fullfile(pathname,filename)};
    end
end


% parse and analyze configuation file(s) if present
VisarData={};
for ii=1:numel(file)
    temp=LoadConfig(file{ii});
    VisarData=[VisarData temp];
end

% default settings
%setappdata(0,'UseNativeSystemDialog',false);

% output analysis based on chosen mode
fig=[];
switch lower(mode)
    case 'gui'
        fig=findall(0,'Type','figure','Tag','PointVISAR');
        if ishandle(fig) % program is already running
            fprintf('Unable to launch PointVISAR--program already running!\n');
            return
        end
        fig=PointVISARGUI(VisarData);
    case 'console'
        for ii=1:numel(VisarData)   
            outputfile=VisarData{ii}.OutputFile;
            if isempty(outputfile)
                label=VisarData{ii}.Label;
                if isempty(label)
                    outputfile=strcat('Record-',num2str(ii),'.out');
                else
                    outputfile=[VisarData{ii}.Label '.out'];
                end
            end
            VisarData{ii}.OutputFile=outputfile;
            SaveSignals(VisarData{ii});
        end      
end

% function output
if isdeployed || nargout>=1
    varargout{1}=fig;
end