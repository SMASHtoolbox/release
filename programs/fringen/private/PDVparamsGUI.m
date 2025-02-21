function PDVparamsGUI(rootfig)

data=get(rootfig,'UserData');
data.params=createGUI(data.params);
data=make_signals(data);
data=mangle_signals(data);
set(rootfig,'UserData',data);
updateGUI(rootfig);

function params=createGUI(params)

% create labels and default entries
label={};
default={};
format='%.6g ';

label{end+1}='Operating wavelength:';
if isfield(params,'wavelength')
    value=params.wavelength;
else
    value=1550e-9; % m
end
default{end+1}=sprintf(format,value);

label{end+1}='Frequency shift:';
if isfield(params,'fshift')
    value=params.fshift;
else
    value=0; % Hz
end
default{end+1}=sprintf(format,value);

label{end+1}='Reference phase (degrees):';
if isfield(params,'ref_phase')
    value=params.ref_phase;
else
    value=0; 
end
default{end+1}=sprintf(format,value);

label{end+1}='Phase shifts (degrees):';
if isfield(params,'phase_shift')
    value=params.phase_shift;
else
    value=[0 +120 -120]; 
end
default{end+1}=sprintf(format,value);

label{end+1}='Reference path scaling:';
if isfield(params,'ref_scale')
    value=params.ref_scale;
else
    value=1; 
end
default{end+1}=sprintf(format,value);

label{end+1}='Target path scaling:';
if isfield(params,'target_scale')
    value=params.target_scale;
else
    value=1; 
end
default{end+1}=sprintf(format,value);

% prompt user for input
answer=inputdlg(label,'VISAR parameters',[1 40],default);
if isempty(answer)
    return
end

% try to make sense of the input
try
    params.wavelength=sscanf(answer{1},'%g',1);
    params.fshift=sscanf(answer{2},'%g',1);
    params.ref_phase=sscanf(answer{3},'%g',1);
    params.phase_shift=sscanf(answer{4},'%g');
    params.ref_scale=sscanf(answer{5},'%g');
    params.target_scale=sscanf(answer{6},'%g');
catch
    % have user try again
    params=createGUI(params);
end