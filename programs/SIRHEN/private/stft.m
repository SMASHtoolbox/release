% stft : short time Fourier transform  analysis 
%
% This function breaks a signal into durations and calculates the frequency
% spectrum of each duration with a FFT.  By default, the spectra are stored in
% a 2D array (frequency X time) for image display. User defined functions
% may also be applied to the individual spectra.
%
% Usage:
%  >> [output,tout,frequency,options]=stft(signal,time,options,localfunc,updatefunc);
%
% Input:
%    signal     : signal data (required)
%    time       : time data or interval between samples (optional)
%    options    : options structure (optional)
%    localfunc  : user defined function handle (optional)
%    updatefunc : user defined function handle (optional)
%
% Analysis options (specified by a structure field) include:
%    Nduration*    : number of analysis durations (default is 8)
%    overlap       : fractional overlap between durations (default is 0)
%    duration*     : time range of each duration
%    durationN*    : number signal points in each duration
%    skip*         : time separation between durations
%    skipN*        : number of points between durations
%    Nfreq*        : number of FFT frequency points (default is 64)
%    window        : FFT window ('boxcar','Hamming','Hann','Blackman','Kaiser')
%    removeDC      : logical value to subtract duration mean prior to FFT
%    normalization : scale spectra by 'global' (default) or 'local' maximum
%    freq_shift    : frequency shift (default is 0, additive)
%    waitbar_inc   : waitbar progress increment (default is 1%)
%    local         : local function data structure (see below)
%    update        : update function data structure (see below)
% Options marked with an asterisk are linked with the following rules.
%   -Nduration overides duration, durationN, skip, and skipN setttings.
%    Use overlap to refine the duration/durationN setting in combination
%    with Nduration.
%   -duration overrides durationN
%   -skip overrides skipN
%   -Nfreq may increase for consistency with durationN
%
% Local analysis can be applied to each duration by passing a function
% handle as the fourth input argument (localfunc).  The function must
% accept three inputs:
%    1.  A column array for frequency data.
%    2.  A column array for intensity data. 
%    3.  A structure for local function data (specified by options.local).
% The local function must return its results as a column array.
% 
% Analysis options can be updated during the STFT calculation by passing a
% function handle as the fifth input argument (updatefunc).  This function
% must accept two inputs:
%    1.  A structure of current options
%    2.  A structure that defines the current state (time, etc.)
% The update function must return an options structure with the same
% fields as the input structure.  Additional data should be passed to the
% update function via options.update.  
%
% Output:
%    output    : 2D array containing frequency spectra or user function results on each column
%    tout      : row vector containing duration centers
%    frequency : column vector containing spectra frequency values
%    options   : structure containing actual option values (specified + default + overrides)

% created April 18, 2008 by Daniel Dolan
% revised December 7, 2009 by Daniel Dolan
% updated October 12, 2010 by Daniel Dolan
%   -various bug fixes
%   -moved location options into the main options structure
%   -added update function capability
function [output,tout,frequency,options]=stft(signal,time,options,...
    localfunc,updatefunc)

% handle missing input
if nargin<1
    error('ERROR: no signal input');
end

if (nargin<2) || isempty(time)
    time=1;
end

if (nargin<3) || isempty(options)
    options=struct();
end

if (nargin<4) || isempty(localfunc)
    localfunc=[];
end

if (nargin<5) || isempty(updatefunc)
    updatefunc=[];
end

% process input, applying defaults where necessary
signal=signal(:);
Nsignal=numel(signal);

tstart=0;
if numel(time)==1 % sampling interval given
    T=time;
else
    T=(time(end)-time(1))/(numel(time)-1);
    tstart=time(1);
end

if ~isfield(options,'overlap')
    options.overlap=[];
end

if isfield(options,'Nduration') % specified number of durations
    options.Nduration=max([options.Nduration 1]);    
    options.durationN=floor(Nsignal/options.Nduration);
    options.duration=T*options.durationN;
    options.skip=options.duration;
    options.skipN=options.durationN;
    if options.overlap>=0
        options.duration=(options.overlap+1)*options.skip;
        options.durationN=floor(options.duration/T);
    end    
else
    % determine duration time/points
    if isfield(options,'duration')
        options.durationN=round(abs(options.duration)/T);        
    elseif isfield(options,'durationN')
        options.durationN=round(abs(durationN));
    else
        options.durationN=floor(Nsignal/8);
    end    
    if rem(options.durationN,2)==0
        options.durationN=options.durationN+1; % force odd number
    end
    options.duration=T*options.durationN;
    % determine skip time/points
    if isfield(options,'skip')
        options.skipN=ceil(abs(options.skip)/T);
    elseif isfield(options,'skipN')
        options.skipN=ceil(abs(options.skipN));
    else
        options.skipN=options.durationN;
    end
    options.skip=T*options.skipN;
    % determine number of durations
    M=(options.durationN-1)/2;   
    temp=(M+1):options.skipN:(Nsignal-M);
    options.Nduration=numel(temp);       
end

Nfreq=64;
if isfield(options,'Nfreq') 
    options.Nfreq=max([Nfreq abs(options.Nfreq)]);
else
    options.Nfreq=Nfreq;
end
options.Nfreq=max([options.Nfreq ceil(options.durationN/2)]);
options.Nfreq=pow2(nextpow2(options.Nfreq));
    
if ~isfield(options,'window') || isempty(options.window)
    options.window='hamming';
end
if ischar(options.window)
    arg=(0:(options.durationN-1))/(options.durationN-1);
    arg=arg(:); % convert to column array
    switch lower(options.window)
        case 'gaussian'
            sigma=options.durationN/6; % Three deviations (both directions)            
            mid=(arg(end)+arg(0))/2;
            window=exp(-(arg-mid).^2/(2*sigma^2));
        case 'hamming'
            window=0.54-0.46*cos(2*pi*arg);
        case {'hann','hanning'}
            window=0.50-0.50*cos(2*pi*arg);
        case 'blackman'
            window=0.42-0.50*cos(2*pi*arg)+0.08*cos(4*pi*arg);
        case 'kaiser'
            beta=sqrt(3)*pi; % match Hamming window lobe width
            %beta=2*sqrt(2*pi); % match Blackman window lobe width
            arg=sqrt(1-(2*arg-1).^2);
            window=besseli(0,beta*arg)/besseli(0,beta);
        case {'boxcar','rectangle','flat','none'}
            window=ones(size(arg));
        otherwise
            error('ERROR: unknown window (''%s'') specified',options.window);
    end
end

if ~isfield(options,'removeDC') || isempty(options.removeDC)
    options.removeDC=false;
end

if ~isfield(options,'normalization') || isempty(options.normalization)
    options.normalization='global';
end

if ~isfield(options,'freq_shift') || isempty(options.freq_shift)
    options.freq_shift=0;
end

if ~isfield(options,'waitbar_inc') || isempty(options.waitbar_inc)
    options.waitbar_inc=0.01;
end

if ~isfield(options,'local')
    options.local=struct();
end

if ~isfield(options,'update')
    options.update=struct();
end

% create output arrays
tout=(0:(options.Nduration-1))*options.skip;
tout=tout+tstart+options.duration/2;

frequency=0:(options.Nfreq-1);
frequency=frequency/(2*options.Nfreq*T);
frequency=frequency(:)+options.freq_shift;

if isa(localfunc,'function_handle')
    output=repmat(nan,[1 options.Nduration]);
else
    output=repmat(nan,[options.Nfreq options.Nduration]);
end

% sweep through the signal
fraction=0;
hwait=waitbar(fraction,'Short Time Fourier Transform progress...',...
    'Name','STFT progress','CreateCancelBtn','delete(gcbf)');
index=1:options.durationN;
portion=zeros(2*options.Nfreq,1);
k=0;
state=struct('time',nan);
while index(end)<=numel(signal)
    k=k+1;
    if k>numel(tout)
        break
    end
    state.time=tout(k);
    temp=signal(index);
    if options.removeDC
        temp=temp-mean(temp);
    end
    temp=temp(:).*window;
    portion(1:options.durationN)=temp;
    transform=fft(portion);
    intensity=transform(1:options.Nfreq);
    intensity=real(intensity.*conj(intensity)); % ensure real result
    if isa(updatefunc,'function_handle')
        options=feval(updatefunc,options,state);
    end
    if isa(localfunc,'function_handle')
        result=feval(localfunc,frequency,intensity,options.local);
        Nresult=size(result,1);
        if size(output,1)~=Nresult
            output=repmat(output(1,:),[Nresult 1]);
        end
        output(:,k)=result;
    else
        output(:,k)=intensity;
    end
    index=index+options.skipN;
    if ishandle(hwait)
        change=k/options.Nduration-fraction;
        if change>=options.waitbar_inc
            fraction=fraction+change;
            waitbar(fraction,hwait);
        end
    else
        break
    end
end
if ishandle(hwait)
    delete(hwait);
end

if isempty(localfunc)
    switch options.normalization
        case 'none'
            % do nothing
        case 'global'
            output=output/max(output(:));
        case 'local'
            localmax=max(output,[],1);
            localmax=repmat(localmax,[size(output,1) 1]);
            output=output./localmax;
        otherwise
            % do nothing
    end
end

if nargout==0
    if isempty(localfunc)
        imagesc(time,frequency,10*log10(output));
        set(gca,'YDir','normal');
    else
        plot(time,output);
    end
end