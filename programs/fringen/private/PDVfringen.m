function data=PDVfringen(data)

% apply default parameters where necessary
params=data.params;
if ~isfield(params,'wavelength') || isempty(params.wavelength)
    params.wavelength=1550e-9; % m
end
if ~isfield(params,'fshift') || isempty(params.wavelength)
    params.fshift=0; % Hz
end
if ~isfield(params,'ref_phase') || isempty(params.ref_phase)
    params.ref_phase=0;
end
if ~isfield(params,'phase_shift') || isempty(params.phase_shift)
    %params.phase_shift=[0 -120 +120]; % THRIVE convention
    params.phase_shift=0;
end
if ~isfield(params,'ref_scale') || isempty(params.ref_scale)
    params.ref_scale=1;
end
if ~isfield(params,'target_scale') || isempty(params.target_scale)
    params.target_scale=1;
end

% replicate parameters as needed
Nsignal=numel(params.phase_shift);
if numel(params.ref_scale)~=Nsignal
    params.ref_scale=repmat(params.ref_scale(1),[1 Nsignal]);
end
if numel(params.target_scale)~=Nsignal
    params.target_scale=repmat(params.target_scale(1),[1 Nsignal]);
end

% store parameters and extract local copies
data.params=params;
wavelength=params.wavelength;
freq_shift=params.fshift;
ref_phase=params.ref_phase*(pi/180);
phase_shift=params.phase_shift*(pi/180);
ref_scale=params.ref_scale;
target_scale=params.target_scale;

% read data and calculate phase difference
data=import_data(data);
data.IT=data.IC+data.IE;
Phi=(4*pi/wavelength(1))*(data.position-data.position(1))+ref_phase+2*pi*freq_shift*data.time;


% calculate PDV signals
%[data.signal{1:Nsignal}]=deal(zeros(size(data.time)));
data.signal=cell(1,Nsignal);
for k=1:Nsignal
    baseline=ref_scale(k)*data.IR+target_scale(k)*data.IT;
    amplitude=2*sqrt(ref_scale(k)*target_scale(k)*data.IR.*data.IC);
    data.signal{k}=baseline+amplitude.*cos(Phi-phase_shift(k));
end