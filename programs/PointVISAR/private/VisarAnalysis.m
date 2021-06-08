function record = VisarAnalysis(record, varargin)
%   VisarAnalysis Provides a gateway to different stages of Visar
%   Analysis.
%   This function provides a gateway to the different stages of VISAR
%   analysis; most of the actual calculations are performed in separate
%   routines called by this function. The user must pass a VISAR record
%   structure to the function. If no other input is given, all stages of
%   the Visar analysis are performed. The output of the function is a new
%   VISAR record structure with results stored in the appropriate fields.
%
%   Example:
%       record = VisarAnalysis(record);   % Perform complete analysis
%       record = VisarAnalysis(record, 'SignalFilter');   % Perform only
%       Signal Filtering
%       record = VisarAnalysis(record, 'SignalFilter', 'QuadratureSignals');
%       
%       The last example performs all analysis operations from signal
%       filtering through the generation of quadrature signals
%       (inclusively). There are six analysis operations, which are
%       performed in the following order.
%
%       'Loadrecord'        Loads raw record from binary or ASCII file
%       'PreProcessing'     Applies filter, signal shifts/scaling, and time
%                           shifts
%       'QuadratureSignals' Generates the quadrature signals
%       'Fringes'           Adds or removes fringes
%       'Velocity'          Calculates the velocity
%       'PostProcessing'    Modifies the analysis results
%
%   Any two operations may be used as start of stop points for the
%   analysis. This capability is intended for use in incremental analysis,
%   as in the PointVISAR program.
%
%   Created by      Daniel Dolan        01/27/2005
%   Modified by     Kevin McCollough    02/03/2005


%   Create the list of VISAR operations in order
oplist={};
oplist{end+1} = 'LoadRecord';
oplist{end+1} = 'PreProcessing';
oplist{end+1} = 'QuadratureSignals';
oplist{end+1} = 'Fringes';
oplist{end+1} = 'Velocity';
oplist{end+1} = 'PostProcessing';

% outrecord = record;

% Parse the input parameters
switch  nargin
    case 0      % No record structure was provided
        error('ERROR: VisarAnalysis:parseInputParams - Missing VISAR record');
    case 1      % Just the record structure was provided
        operList = oplist;
    case 2      % record structure, with a starting operation were given
        operList{1} = varargin{1};
    case 3      % record structure, with starting and stoping ops were given
        firstOp = varargin{1};
        firstOpValidated = false;
        secndOp = varargin{2};
        secndOpValidated = false;
        
        for ii=1:numel(oplist)
            if strcmp(firstOp, oplist{ii})
                startOpIndex = ii;
                firstOpValidated = true;
            end
            if strcmp(secndOp, oplist{ii})
                stopOpIndex = ii;
                secndOpValidated = true;
            end
        end
        
        % Check that a valid starting operation was given
        if ~firstOpValidated
            error('ERROR: VisarAnalysis:parseInputParams - Invalid starting operation');
        end
        
        % Check that a valid stoping operation was given
        if ~secndOpValidated
            error('ERROR: VisarAnalysis:parseInputParams - Invalid stopping operation');
        end
        
        % Check that the start and stop ops are in the correct order
        if (startOpIndex > stopOpIndex)
            error('ERROR: VisarAnalysis:parseInputParams - Invalid operation ordering');
        end
        
        % Set operations list to be all operations between the startOp and
        % stopOp
        jj = 1;
        while (startOpIndex <= stopOpIndex)
            operList{jj} = oplist{startOpIndex};
            startOpIndex = startOpIndex + 1;
            jj = jj + 1;
        end
end

% Iterate through the list of operations
for ii=1:numel(operList)     
    switch operList{ii}
        case oplist{1}      % Load record
            record=LoadSignals(record);
            for jj=1:record.NumSignals
                record.RawSignalTime{jj}=...
                    record.SignalTimeScale*record.RawSignalTime{jj};
            end
        case oplist{2}      % Pre-processing
            for jj=1:record.NumSignals
                % filtering
                record.Signal{jj}=FilterSignal(record.RawSignal{jj},...
                    record.FilterName,record.FilterParams);
                % vertical offsets and scaling
                record.Signal{jj}=record.SignalScale(jj)*...
                    (record.Signal{jj}+record.SignalVerticalShift(jj));
                % time shifts
                record.SignalTime{jj}=record.RawSignalTime{jj}...
                    +record.SignalTimeShift(jj)+record.TimeShift;
            end 
            % generate common time base
            for jj=1:record.NumSignals
                tmin(jj)=min(record.SignalTime{jj});
                tmax(jj)=max(record.SignalTime{jj});
                dt(jj)=(tmax(jj)-tmin(jj))/numel(record.SignalTime{jj}); % average time step
            end
            tmin=max(tmin);
            tmax=min(tmax);
            dt=max(dt);
            N=ceil((tmax-tmin)/dt);
            record.Time=linspace(tmin,tmax,N);            
        case oplist{3}      % Generate Quadrature Signals
            time=record.Time;
            % identify initial and experiment regions
            InitialTime=record.InitialTime;
            index=(time>=InitialTime(1)) & (time<=InitialTime(2));
            if ~any(index) % no data in initial domain--use first point
                index=1;
            end
            inittime=time(index);
            ExperimentTime=record.ExperimentTime;
            index=(time>=ExperimentTime(1)) & (time<=ExperimentTime(2));
            time=time(index);
            record.Time=time;
            %generate quadrature signals
            switch lower(record.Type)
                case 'conventional'
                    % initial region
                    Dx0=(interp1(record.SignalTime{1},record.Signal{1},...
                        inittime,'linear'));
                    Dy0=(interp1(record.SignalTime{2},record.Signal{2},...
                        inittime,'linear'));
                    BIM0=(interp1(record.SignalTime{3},record.Signal{3},...
                        inittime,'linear'));
                    Dx0=Dx0./BIM0;
                    Dy0=Dy0./BIM0;  
                    % experiment region                   
                    Dx=interp1(record.SignalTime{1},record.Signal{1},...
                        time,'linear');
                    Dy=interp1(record.SignalTime{2},record.Signal{2},...
                        time,'linear');
                    BIM=interp1(record.SignalTime{3},record.Signal{3},...
                        time,'linear');
                    Dx=Dx./BIM;
                    Dy=Dy./BIM;
                case 'pushpull2'
                    % initial region
                    Dx0=(interp1(record.SignalTime{1},record.Signal{1},...
                        inittime,'linear'));
                    Dy0=(interp1(record.SignalTime{2},record.Signal{2},...
                        inittime,'linear'));
                    % experiment region
                    Dx=interp1(record.SignalTime{1},record.Signal{1},...
                        time,'linear');
                    Dy=interp1(record.SignalTime{2},record.Signal{2},...
                        time,'linear');
                case 'pushpull4'
                    % initial region
                    D1A0=(interp1(record.SignalTime{1},record.Signal{1},...
                        inittime,'linear'));
                    D1B0=(interp1(record.SignalTime{2},record.Signal{2},...
                        inittime,'linear'));
                    D2A0=(interp1(record.SignalTime{3},record.Signal{3},...
                        inittime,'linear'));
                    D2B0=(interp1(record.SignalTime{4},record.Signal{4},...
                        inittime,'linear'));
                    Dx0=D1A0-D1B0;
                    Dy0=D2A0-D2B0;
                    % experiment region
                    D1A=interp1(record.SignalTime{1},record.Signal{1},...
                        time,'linear');
                    D1B=interp1(record.SignalTime{2},record.Signal{2},...
                        time,'linear');
                    D2A=interp1(record.SignalTime{3},record.Signal{3},...
                        time,'linear');
                    D2B=interp1(record.SignalTime{4},record.Signal{4},...
                        time,'linear');
                    Dx=D1A-D1B;
                    Dy=D2A-D2B;
                otherwise
                    error('ERROR: VisarAnalysis - Unknown VISAR type.');
            end             
            record.D{1}=Dx;
            record.D{2}=Dy;                       
            % calculate phase difference
            x0 = record.Ellipse(1);
            y0 = record.Ellipse(2);
            Lx = record.Ellipse(3);
            Ly = record.Ellipse(4);
            epsilon = record.Ellipse(5);
            xR=(Dx0-x0)/Lx;
            yR=(Dy0-y0)/Ly;
            % sign convention matches ellipse fit
            phaseR=atan2(yR+xR*sin(epsilon),xR*cos(epsilon));   
            phaseR=mean(unwrap(phaseR));
            x=(Dx-x0)/Lx;
            y=(Dy-y0)/Ly;
            phase=atan2(y+x*sin(epsilon),x*cos(epsilon));                      
            phase=unwrap(phase,pi); % deal with phase wraps   
            record.FringeShift=(phase-phaseR)/(2*pi);
            % calculate contrast
            contrast0=sqrt(Dx0.^2+2*Dx0.*Dy0*sin(epsilon)+Dy0.^2)*sec(epsilon);
            contrast0=mean(contrast0);
            contrast=sqrt(Dx.^2+2*Dx.*Dy*sin(epsilon)+Dy.^2)*sec(epsilon);
            if (contrast0<min(contrast)) || (contrast0==0);
                %warndlg(...
                %    'Low initial contrast--check initial time setting',...
                %    'Low initial contrast');
            else 
                contrast=contrast/contrast0;
            end
            record.Contrast=contrast;               
        case oplist{4}      % Add / Remove fringes
            for jj=1:numel(record.AddJumps)
                if isempty(record.JumpWidth) || (record.JumpWidth==0)
                    jump = (record.Time >= record.AddJumps(jj));
                else
                    jump=SmearJump(record.Time,record.AddJumps(jj),record.JumpWidth);
                end
                record.FringeShift=record.FringeShift+jump;
            end
            for kk=1:numel(record.SubtractJumps)
                if isempty(record.JumpWidth) || (record.JumpWidth==0)
                    jump = (record.Time >= record.SubtractJumps(kk));
                else
                   jump=SmearJump(record.Time,record.SubtractJumps(kk),record.JumpWidth); 
                end
                record.FringeShift=record.FringeShift-jump;
            end            
        case oplist{5}      % Calculate the velocity
            v0=record.InitialVelocity;    
            switch lower(record.Analysis)
                case 'displacement' % exact approach
                    params=record.DerivativeParams;
                    if isempty(params)
                        params=[1 3];
                    end                    
                    dFdt=SmoothDerivative(params,record.FringeShift,record.Time);                                                            
                    dFdt(isnan(dFdt))=0; % removed nan values at boundaries
                    N=numel(record.Time);
                    T=(record.Time(end)-record.Time(1))/(N-1);
                    record.Velocity=zeros(size(record.Time));
                    for n=1:N
                        told=record.Time(n)-record.Delay;
                        if told<record.Time(1)
                            vold=v0;
                            aold=0;
                        else
                            vold=interp1(record.Time,record.Velocity,told,'linear','extrap');
                            aold=interp1(record.Time,record.Velocity,[told-T told+T],'linear','extrap');
                            aold=(aold(2)-aold(1))/(2*T); % central difference
                        end
                        record.Velocity(n)=vold+(record.Wavelength/2)*dFdt(n);
                        if isempty(record.Dispersion) || isnan(record.Dispersion)
                            % do nothing
                        else
                            record.Velocity(n)=record.Velocity(n)-record.Dispersion*record.Delay*aold;
                        end
                    end
                otherwise
                    if strcmpi(record.Analysis,'velocity')
                        % do nothing
                    else
                        fprintf('%s is not a valid analysis mode.\n',record.Analysis);
                        fprintf('Using velocity analysis instead.\n');
                    end
                    record.Velocity = v0+record.VPF*record.FringeShift;
                    if isempty(record.Delay) || isnan(record.Delay)
                        % do nothing
                    elseif isempty(record.Dispersion) || isnan(record.Dispersion)
                        shift=record.Delay/2;
                        record.Time=record.Time-shift; % revised VISAR approx
                    else
                        gamma=(0.50+record.Dispersion)/(1+record.Dispersion);
                        shift=gamma*record.Delay;
                        record.Time=record.Time-shift; % revised VISAR approx
                    end
            end          
        case oplist{6}      % Post Processing
            % do something?
        otherwise           % Unknown operation
            error('ERROR: VisarAnalysis - Unknown VISAR operation');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=SmearJump(t,t0,tr)

T=tr/(2*atanh(4/5));
func=(1+tanh((t-t0)/T))/2;
