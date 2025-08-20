function AboutPointVISAR()

message={};

[version,versiondate]=PointVISARversion;
message{end+1}=['PointVISAR version ' version];
message{end+1}=['Released ' versiondate];
message{end+1}='';
message{end+1}='Do not distribute without permission!';
message{end+1}='';
message{end+1}='Created by:';
message{end+1}='     Daniel Dolan (Sandia National Laboratories)';
message{end+1}='     Ed Kaltenbach and Kevin McCollough (Applied Research Associates)';

msgbox(message,'About PointVISAR');