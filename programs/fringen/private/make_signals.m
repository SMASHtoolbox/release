function data=make_signals(data)

if ~isfield(data,'mode')
    data.mode='VISAR';
end

if ~isfield(data,'params')
    data.params=struct();
end

switch upper(data.mode)
    case 'PDV'
        data=PDVfringen(data);
    case 'VISAR'
        data=VISARfringen(data);
    otherwise
        fprintf('%s is not a valid mode',data.mode);
end