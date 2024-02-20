%   LoadConfig  Loads a PointVISAR configuration file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,status]=LoadConfig(filename)

% input check
if nargin<1
    filename='';
end

% parse the configuration file
[data,status,filename]=ParseConfig(filename);
if isempty(data) 
    return
end

% interpret the configuration file
[data,status]=InterpConfig(data,filename);

% process each record
for ii=1:length(data)
    % Analyze each record
    data{ii}=VisarAnalysis(data{ii});
    
    % set administrative 
    data{ii}.NewRecord=false;
    data{ii}.LineColor=DistinguishedLines(ii);
end