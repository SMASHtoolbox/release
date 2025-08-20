% agilent_h5read : read Agilent HDF5 binary data files
%
% This function reads files data created by Agilent digitizers
% stored in the HDF5 format (*.h5).  These files contain one or more
% signals in a binary format.
%
% Usage:
%   >> [signal,time,label]=agilent_h5read(filename,index);
% If filename is omitted or empty (''), the user will be prompted to
% select a file.  If the index is omitted, the function returns the first
% signal stored in the file.  Specific signals can be accessed by passing
% an integer:
%   >> [signal,time]=agilent_h5read(filename,2);
% Setting index='all' returns every signal from the file; passing
% index='gui' prompts the user to select a *single* signal within the file.
%
% When a single signal is extracted, the function return numerical
% (signal/time) and textual (label) arrays.  Cell array outputs are used
% for multiple signal extraction.

% created December 19, 2011 by Daniel Dolan (Sandia National Labs)
function [signal,time,label]=agilent_h5read(filename,index)

% handle input
if (nargin<1) || isempty(filename)
    types={};
    types(end+1,:)={'*.h5;*.H5','Agilent HDF5 files'};
    types(end+1,:)={'*.*','All files'};
    [filename,pathname]=uigetfile(types,'Select Agilent data file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    filename=fullfile(pathname,filename);
end

if (nargin<2) || isempty(index)
    index=1;
end

% extract header information
info=hdf5info(filename);
info=info.GroupHierarchy.Groups(3);
num_signal=info.Attributes.Value;

% prompt user to select signal (GUI mode)
if strcmpi(index,'gui')
    choice=cell(num_signal,1);
    for n=1:num_signal
        [~,choice{n}]=fileparts(info.Groups(n).Name);
    end
    [index,ok]=listdlg(...
        'PromptString','Select signal for import',...
        'Name','Select signal',...
        'ListString',choice,...
        'SelectionMode','single');
    if ~ok % user pressed cancel or closed the dialog
        return
    end    
elseif strcmp(index,'all')
    index=1:num_signal;
end  

% extract data
[signal,time,label]=deal(cell(numel(index),1));
for n=1:numel(index)
    group=info.Groups(index(n));
    label{n}=group.Name;
    name=group.Datasets.Name;
    signal{n}=h5read(filename,name);
    signal{n}=signal{n}(:);
    numpoints=numel(signal{n});
    dx=group.Attributes(8).Value;
    left=group.Attributes(9).Value;    
    right=left+(numpoints-1)*dx;
    time{n}=left:dx:right;
    time{n}=time{n}(:);
end

if numel(signal)==1
    signal=signal{1};
    time=time{1};
    label=label{1};
end