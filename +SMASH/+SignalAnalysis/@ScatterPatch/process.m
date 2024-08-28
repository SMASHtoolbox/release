function varargout=process(object,ProcessFcn,time)

% manage input
if (nargin < 2) || isempty(ProcessFcn) || strcmpi(ProcessFcn,'weighted')
    ProcessFcn=@weightBlocks;
else
    if ischar(ProcessFcn)
        ProcessFcn = str2func(ProcessFcn);
    end
end

if (nargin < 3) || isempty(time)
    time=uniquetol(object.MappedData(:,1));
else
    
end

%
data=object.MappedData;
data=data(logical(data(:,6)),1:4);
try
    result=ProcessFcn(data,time);
catch ME
    throwAsCaller(ME);
end

object.Result=result;

end

function out=weightBlocks(data,time)

N=numel(time);

out=nan(N,3);
for n=1:N
    t0=time(n);
    out(n,1)=t0;
    keep=(abs(data(:,1)-t0) <= 2*data(:,3));
    if sum(keep) == 0
        continue
    end   
    local=data(keep,:);   
    Delta=(local(:,1)-t0)./local(:,3);
    sigma=local(:,4).*sqrt(1+Delta.^2);
    w=1./sigma.^2;
    out(n,2)=sum(w.*local(:,2))/sum(w);
    out(n,3)=1./sqrt(sum(w));
end

out={out};

end

function out = weightBlocks_noSmoothing(data,time)

% Performs weighted average at each time, without incorporating overlapping
% blocks from other time centers. Incorporation of overlapping blocks from
% other time centers may produce an undesired smoothing effect.

% Written by Nathan Brown (npbrown@sandia.gov)

N = numel(time);
out = nan(N, 3); % [t f df]

for ii = 1:N
    
    % get data relevant to this time step
    
    t0 = time(ii);
    out(ii, 1) = t0;
    keep = data(:,1) == t0;
    local = data(keep,:);
    
    % apply weighted averaging
    
    w = 1./local(:,4).^2;
    f = sum(w.*local(:,2))/sum(w);
    out(ii, 2) = f;
    
    % compute uncertainty (still thinking about best way to do this)
    
    df_right = (local(:,2) + local(:,4)) - f;
    df_left = f - (local(:,2) - local(:,4));
    
    w_right = w;
    w_left = w;
    w_right(df_right <= 0) = 0;
    w_left(df_left <= 0) = 0;
    
    df_right_weighted = sum(w_right.*df_right)/sum(w_right);
    df_left_weighted = sum(w_left.*df_left)/sum(w_left);
    df = mean([df_right_weighted, df_left_weighted]);
    out(ii, 3) = df;
    
end

out = {out};

end