function options=updateoptions(options,state)

% extract information from option structure
local=options.local;
update=options.update;

% change information based on current state
t_current=state.time;
if isempty(update.flimitpoints) %isinf(update.flimitpoints(1))
    local.xmin = [];
    local.xmax = [];
else 
    %fcenter_current=interp1(options.update.tlimitpoints,options.update.flimitpoints,t_current,'spline');
    fcenter=interp1(update.tlimitpoints,update.flimitpoints,t_current,...
        'linear','extrap');
    Df=update.fwidth/2;
    %local.xmin = max(fcenter - Df,0); % not necessary (x bounded by FFT)
    %local.xmax = min(fcenter + Df,30e9); % not necessary (x bounded by FFT)
    local.xmin = fcenter - Df;
    local.xmax = fcenter + Df;
end

% update options structure
options.local=local;

end