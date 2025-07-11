function data=VISARfringen(data)

% apply default parameters where necessary
params=data.params;
if ~isfield(params,'wavelength') || isempty(params.wavelength)
    params.wavelength=532e-9; % m
end
if ~isfield(params,'delay') || isempty(params.delay)
    params.delay=1e-9; % s
end
if ~isfield(params,'dispersion') || isempty(params.dispersion)
    params.dispersion=0;
end
if ~isfield(params,'ref_phase') || isempty(params.ref_phase)
    params.ref_phase=0;
end
if ~isfield(params,'phase_shift') || isempty(params.phase_shift)
    %params.phase_shift=[0 pi pi/2 3*pi/2];
    params.phase_shift=[0 180 90 270];
end
if ~isfield(params,'ref_scale') || isempty(params.ref_scale)
    params.ref_scale=1;
end
if ~isfield(params,'delay_scale') || isempty(params.delay_scale)
    params.delay_scale=1;
end

% replicate parameters as needed
Nsignal=numel(params.phase_shift);
if numel(params.ref_scale) ~= Nsignal
    params.ref_scale=repmat(params.ref_scale(1),[1 Nsignal]);
end
if numel(params.delay_scale) ~= Nsignal
    params.delay_scale=repmat(params.delay_scale(1),[1 Nsignal]);
end

% store parameters and extract local copies
data.params=params;
wavelength=params.wavelength;
delay=params.delay;
dispersion=params.dispersion;
ref_phase=params.ref_phase*(pi/180);
phase_shift=params.phase_shift*(pi/180);
ref_scale=params.ref_scale;
delay_scale=params.delay_scale;

% read data and calculate phase difference
data=import_data(data);
data.IT=data.IC+data.IE;
timeB=data.time-delay;
Phi=data.position-interp1(data.time,data.position,timeB,'linear',0);
Phi=Phi+(dispersion*delay)*interp1(data.time,data.velocity,timeB,'linear',0);
Phi=(4*pi/wavelength)*Phi+ref_phase;

% calculate PDV signals
%[data.signal]=deal(zeros(size(data.time)));
data.signal=cell(1,Nsignal);
for k=1:Nsignal
    baseline=(ref_scale(k)+delay_scale(k))*data.IT;
    amplitude=2*sqrt(ref_scale(k)*delay_scale(k))*data.IC;
    data.signal{k}=baseline+amplitude.*cos(Phi-phase_shift(k));
end