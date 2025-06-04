function varargout = lpsvd(object,varargin)
% Linear Prediction with Singular Value Decomposition
%
% This code uses lpsvd to find poles of a damped sinusoid and extracts out
% the decay, frequency, phase, and amplitude. This version uses the forward
% prediction method.
% Model used for fitting data:
%       y(t) = sum_i=1^N [ exp(-beta_i*t) * cos(omega_i * t + phi_i) ]
% where "N" is the number of sinusoids, "beta" is the decay rate, "omega" 
% is the frequency, and "phi" is the phase.
%
% references: Kumaresan and Tufts, IEEE Transactions on acoustic, speech, 
%             and signal processing (1982)
%
% Added option to multiply the signal with an artificial decay constant
% to agree with the model and allocates the maximum number of frequencies 
% (required for parallel processing).
%
% The calling syntax is:
%   >> [frequency,amplitude,phase,decay] = lpsvd(object,name,value,...);
% where name/value pairs specify options for the lpsvd calculation. Up to
% four output arguments are returned.
%   -"frequency" is an array of all the frequencies recovered
%   -"amplitude" is an array of all the amplitudes corresponding to the
%   frequencies
%   -"phase" is an array of all the phases corresponding to the frequencies
%   -"decay" is an array of all the decays corresponding to the frequencies
%
% The number of output frequencies, number of sinusoids to fit data, and
% number of sv to use can be specified by name:
%   NumberFrequencies - number of output frequencies (default = 4)
%   L - number of sinusoids to use to fit data (default = 0.75n)
%   nM - number of sv to use (default = 8)
% A cell array should be used to pass parameters
%   >> [...]=lpsvd(object,'NumberFrequencies',value,...)
%
% created May 1, 2018 by Samuel D. Park (Sandia National Laboratories)
%
%
% changelog:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% manage option
% default options
option=struct('NumberFrequencies',4,'L',0.75,'nM',8,'Decay',0);

% read varargin
Narg=numel(varargin);
if Narg==1
    if isstruct(varargin{1})
        name=fieldnames(varargin{1});
        for i=1:numel(name)
            if isfield(option,name{i})
                option.(name{i}) = varargin{1}.(name{i});
            else
                fprintf('Ignoring invalid option "%s\n',name{i})
            end
        end
    else
       error('ERROR: invalid option specification'); 
    end
elseif rem(Narg,2)==0
    for i=1:2:Narg
        name=varargin{i};
        assert(ischar(name),'ERROR: invalid option name');
        if isfield(option,name)
            option.(name)=varargin{i+1};
        else
            fprintf('Ignoring invalid option "%s\n',name);
        end
    end
else
    error('ERROR: unmatched name/value pair');
end

%% verify uniform grid
object=makeGridUniform(object);

% extract time and signal
[time,signal]=limit(object);

%% verify options
% maximum number of frequencies to list
value=option.NumberFrequencies;
if ~isnumeric(value) || any(value~=round(value)) || any(value<1)
    error('ERROR: invalid NumberFrequencies setting');
elseif (numel(value)==1) && ~isinf(value)
else
    error('ERROR: invalid NumberFrequencies setting');
end

value=option.L;
if ~isnumeric(value) || any(value>1)
    error('ERROR: invalid L setting')
elseif (numel(value)==1) && ~isinf(value)
else
    error('ERROR: invalid L setting')
end

value=option.nM;
if ~isnumeric(value) || any(value<1)
    error('ERROR: invalid nM setting')
elseif (numel(value)==1) && ~isinf(value)
else
    error('ERROR: invalid nM setting')
end

numpoints=numel(signal);
dt = (time(end)-time(1))/(numpoints-1);
%% determine frequencies using lpsvd
N = length(signal);
%signal = reshape(signal,[N,1]);

% multiply signal with exponential decay for model
arg=(0:(numpoints-1))';
arg=arg/(numpoints-1);
signal = signal.*exp(-option.Decay*arg);

% number of sinusoids to fit
M = N-floor(option.L*N);

% create hankel matrix
% A*b = h
A = hankel(signal(2:M+1),signal((M+1):N));
h = signal(1:M);

% SVD of hankel matrix > A = U * W * Vt
[U, W, V] = svd(A,0); % edit SDP - added 0 for econ
% w = diag(W);

% commented out
% % estimate model order
% % from Kumareson and Tufts 1982
% if nargin < 5
%     mdl = [];
%     for i = 0:L-1
%         val = -N*sum(log(W(i+1:L))) + ...
%             N*(L-i)*log((sum(W(i+1:L))/(L-i))) + i*(2*L-i)*log(N)/2;
%         mdl = [mdl; val];
%     end
%     [~, nM] = min(mdl);
%     % NUMBER OF SINGULAR VALUES TO USE
%     nM = nM + 8;
% end

% cadzow filtration to make the diagonal matrix, W, a square matrix
Wtrunc = W(1:option.nM,1:option.nM);

% linear least squares predition
% solve for vector "b"
b = V(:,1:option.nM)*pinv(Wtrunc)*transpose(U(:,1:option.nM))*h;
% COMMENT: for some reason, inv(W_trunc) does not seem to converge well.

% find poles
qroots = roots([1 -b']);

% throw away poles lying inside of unit circle (noise)
qsig = qroots(abs(qroots) >= 1);

% pre-allocate array with NaN
varargout{1} = NaN(option.NumberFrequencies,1); % frequency
varargout{2} = NaN(option.NumberFrequencies,1); % amplitude
varargout{3} = NaN(option.NumberFrequencies,1); % phase
varargout{4} = NaN(option.NumberFrequencies,1); % decay

if ~isempty(qsig)

    % turn poles into primitive fit parameters
    q = -log(qsig);
    
    % find amplitude and phase - SVD not necessary?
    timeInd = 0:1:(N-1);
    Z = zeros(N,length(q));
    for i = 1:length(q)
        Z(:,i) = exp(q(i)).^(timeInd).';
    end
    
    aa = Z\signal;
    
    % calculate using SVD - more accurate?
    %[U,W,V] = svd(Z,0);
    %w = diag(W);
    %k = length(w);
    %aa = (U(:,1:k)*diag(1./w(1:k))*V(:,1:k)')' * signal;
    
    % frequencies comes in pairs with +/- frequencies - conj phase
    betaInd = real(q(1:2:end));
    freqInd = abs(imag(q(1:2:end)));
    
    nFreq = length(freqInd);

    out(1:nFreq,1) = freqInd/dt/2/pi;
    out(1:nFreq,2) = 2*abs(aa(1:2:end));
    out(1:nFreq,3) = angle(aa(1:2:end));
    out(1:nFreq,4) = betaInd/dt;        
    
    % sort data by amplitude
    outsort = sortrows(out,-3);
    
    % truncate array
    if nFreq < option.NumberFrequencies
        varargout{1}(1:nFreq) = outsort(1:nFreq,1);
        varargout{2}(1:nFreq) = outsort(1:nFreq,2);
        varargout{3}(1:nFreq) = outsort(1:nFreq,3);
        varargout{4}(1:nFreq) = outsort(1:nFreq,4);
    else
        
        varargout{1}(1:option.NumberFrequencies) = ...
            outsort(1:option.NumberFrequencies,1);
        varargout{2}(1:option.NumberFrequencies) = ...
            outsort(1:option.NumberFrequencies,2);
        varargout{3}(1:option.NumberFrequencies) = ...
            outsort(1:option.NumberFrequencies,3);
        varargout{4}(1:option.NumberFrequencies) = ...
            outsort(1:option.NumberFrequencies,4);
    end
end % end if
end % end function