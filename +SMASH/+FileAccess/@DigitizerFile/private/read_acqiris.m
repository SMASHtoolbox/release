function [signal,time]=read_acqiris(filename,index,acquisition,segment)

% manage input
if (nargin<1) || isempty(filename)
    types={};
    types(end+1,:)={'*.h5;*.H5','Acqiris HDF5 files'};
    types(end+1,:)={'*.*','All files'};
    [filename,pathname]=uigetfile(types,'Select Acqiris data file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    filename=fullfile(pathname,filename);
end

if (nargin<2) || isempty(index)
    index=1;
end

report=probe_acqiris(filename);
target=sprintf('/Acquisition.%d/Segment.%d.ch%d.0',acquisition,segment,index);
signal=h5read(filename,target);
target=sprintf('/Header/Instrument/Channel.ch%d',index);
offset=h5readatt(filename,target,'offset');
gain=h5readatt(filename,target,'gain');
signal=gain*double(signal)+offset;

time=repmat(report.increment,size(signal));
time=cumsum(time);
time=time-time(1)+report.delay;



% % read attributes
% location=sprintf('/Waveforms/Channel %d',index);
% name={'XInc' 'XOrg' 'YInc' 'YOrg'};
% for n=1:numel(name)
%     param.(name{n})=h5readatt(filename,location,name{n});
% end
% 
% % read and convert data
% location=sprintf('/Waveforms/Channel %d/Channel %dData',index,index);
% signal=h5read(filename,location);
% signal=param.YOrg+signal*param.YInc;
% time=0:(numel(signal)-1);
% time=param.XOrg+time*param.XInc;