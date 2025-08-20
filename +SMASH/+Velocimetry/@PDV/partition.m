% partition Manage analysis partitions
%
% This method manages the partitions used in history and spectrogram
% generation. Partitioning is described by six parameters, any two of which
% define the other four.
%    object=partition(object,'Blocks',[blocks overlap]); 
%    object=partition(object,'Duration',[duration advance]);
%    object=partition(object,'Points',[points skip]);
% The first parameter parameter (blocks, duration, or points) is mandatory,
% while the second parameter (overlap, advance, or skip) is optional.
%
% NOTE: partition changes make complete history data obsolete.
%
% The Partition property shows the current values for all six parameters.
%    data=object.Partition;
%
% See also PDV, generateHistory, generateSpectrogram
%

%
% created February 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=partition(object,varargin)

if nargin == 1
    fprintf('Partition settings:\n');
    disp(object.Partition);
    return
elseif strcmpi(varargin{1},'default')
    varargin{1}='Blocks';
    varargin{2}=[1000 0];
end

old=object.Partition;
try
    for n=1:object.NumberChannels
        object.Channel{n}=partition(object.Channel{n},varargin{:});
    end
catch
    error('ERROR: invalid partition setting(s)');
end
new=object.Partition;

if new.Points ~= old.Points
    object=changeStatus(object,'obsolete','Noise','History');
end
varargout{1}=object;

end