
%%%%%%%%%%%%%%%%%%%%%%%%%%
function CommandLineHelp()

%type CommandLineHelp.txt

fprintf('PointVISAR: a multi-channel VISAR analysis program\n');
[version,versiondate]=PointVISARversion;
fprintf('Version %s (%s)\n',version,versiondate);
fprintf('\n');

fprintf('Graphical mode:\n');
fprintf('\t PointVISAR\n');
fprintf('Graphical mode (preload data from a configuration file):\n');
fprintf('\t PointVISAR configfile\n');
fprintf('An optional flag ''-gui'' may also be used:\n');
fprintf('\t PointVISAR -gui \n');
fprintf('\n');

fprintf('Console mode (no graphics):\n');
fprintf('\t PointVISAR -console configfile \n');
fprintf('If no configuration file is given, the user will be prompted for one.\n');
fprintf('\n');

fprintf('Created by:\n');
fprintf('\t Daniel Dolan (Sandia National Laboratories) \n');
fprintf('\t Kevin McCollough and Ed Kaltenback (Applied Research Associates) \n');

% 
% %%%%%%%%%%%%%%%%
% Version history:
%     Version 2.1 created May 17, 2005
%     Version 2.2 created May 31, 2005
%     Version 2.3 releaed on July 7, 2005