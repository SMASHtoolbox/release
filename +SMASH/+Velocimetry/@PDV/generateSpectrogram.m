% generateSpectrogram Generate spectrograms
%
% This method generates time-frequency spectrograms for each measurement
% channel.
%    object=generateSpectrogram(object);
% Spectrogram appearance is controlled by the current partition and FFT
% settings.  These settings are recorded in the SpectrogramSettings
% property, which is only changes when this method is called.
%
% See also PDV, calculateOffset,partition, view
%

%
% created January 29, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=generateSpectrogram(object)

object.SpectrogramSettings.FFToptions=object.FFToptions;
object.SpectrogramSettings.Partition=object.Partition;

% generate spectrograms(s)
object.PrivateSpectrogram=cell(size(object.Channel));
for n=1:object.NumberChannels
    fprintf('Generating spectrogram %d...',n);
    % analyze with spectrogram settings
    object.Channel{n}.Normalization='global';   
    object.PrivateSpectrogram{n}=analyze(object.Channel{n});    
    object.Channel{n}.Normalization='none';   
    fprintf('done\n');
end

object.Status.Spectrogram='complete';

end