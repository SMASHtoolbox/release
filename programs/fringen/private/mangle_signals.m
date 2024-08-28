function data=mangle_signals(data)

% apply default parameters where necessary
params=data.params;
if ~isfield(params,'coupling') || isempty(params.coupling)
    params.coupling='DC';
end
if ~isfield(params,'impulse_response')
    params.impulse_response='';
end

if isfield(params,'noise_fraction')
    params.noise_frac=params.noise_fraction;
end
if ~isfield(params,'noise_frac') || isempty(params.noise_frac)
    params.noise_frac=0;
end

if ~isfield(params,'noise_seed')
    params.noise_seed=[];
end
if ~isfield(params,'bit_range') || isempty(params.bit_range)
    params.bit_range=8;
end

% store parameters and extract local copies
data.params=params;
coupling=params.coupling;
impulse_response=params.impulse_response;
noise_frac=params.noise_frac(1);
noise_seed=params.noise_seed;
bit_range=params.bit_range(1);

% reset random number generator if there is a noise seed
if isempty(noise_seed)
    % do nothing
else
    noise_seed=uint32(noise_seed);
    s=RandStream('mt19937ar');
    %RandStream.setDefaultStream(s);
    reset(s,noise_seed);
end

% mangle each signal
Nlevel=floor(pow2(bit_range));
Nsignal=numel(data.signal);
for k=1:Nsignal
    % AC coupling
    if strcmp(coupling,'AC')
        before=(data.time<0);
        if sum(before)>0
            baseline=mean(data.signal{k}(before));
        else
            baseline=data.signal{k}(1);
        end
        data.signal{k}=data.signal{k}-baseline;
    end
    % transfer function
    if ~isempty(impulse_response)
        Nsignal=numel(data.signal{k});
        N2=pow2(nextpow2(Nsignal));
        if k==1 % access inpulse function file
            temp=ColumnReader(impulse_response);
            keep=(temp(:,1)>=0); % drop negative times
            impulse.time=temp(keep,1);
            impulse.signal=temp(keep,2);
            Nimpulse=numel(impulse.signal);
            % calculate normalized transfer function
            transfer=fft(impulse.signal,N2);
            junk=fft(ones(size(data.signal{k})),N2);
            junk=real(ifft(junk.*transfer));
            junk=junk(Nimpulse:Nsignal); % remove impulse and padded sections
            scale=mean(junk);
            transfer=transfer/scale;
        end        
        % perform convolution in frequency domain                       
        transform=fft(data.signal{k},N2);          
        temp=ifft(transform.*transfer);       
        data.signal{k}=real(temp(1:Nsignal));                               
    end
    
    % random noise
    amplitude=noise_frac*(max(data.signal{k})-min(data.signal{k}))/2;
    noise=amplitude*randn(size(data.signal{k}));
    data.signal{k}=data.signal{k}+noise;
    % map data to digitizer levels
    Dmax=max(data.signal{k});
    Dmin=min(data.signal{k});
    range=Dmax-Dmin;
    data.signal{k}=(data.signal{k}-Dmin)/range;
    data.signal{k}=round((Nlevel-1)*data.signal{k})/(Nlevel-1);
    data.signal{k}=Dmin+range*data.signal{k};           
end