% This package manages access to text and binary files.  The function:
%    SupportedFormats - lists all supported file formats
%
% Functions provided in this toolbox are the easiest way to access files.
%    probeFile     - Reveal contents in a multi-record file (*.sda, *.pff, etc.)
%    readFile      - Read data from a file
%    writeFile     - Write data to a file
%
%    mat2sda       - Convert MATLAB *.mat file to an archive
%    sda2mat       - Convert archive to a MATLAB *.mat file
%    sda2workspace - Load archive into current workspace
%    workspace2sda - Save workspace variables to an archive
%
%    mergeSplits - Merge split SDA files into a complete file
%    splitFile   - Split file across multiple SDA files
%
%
% Classes provide more advanced file access.
%    ColumnFile    - text files containing columns
%    CustomFile    - custom text files
%    DIGfile       - Nevada Test Site DIG files
%    DigitizerFile - digitizer binary files
%    LUNA          - LUNA optical backscatter reflectometer files (*.obr) 
%    ImageFile     - CCD, film, image plate, and standard graphic files
%    ParameterFile - text files with named parameter blocks
%    PFFfile       - Sandia Portable File Format files
%    SDAfile       - Sandia Data Archive files
%
% See also SMASH, SMASHtoolbox
%

% Last updated May 10, 2018