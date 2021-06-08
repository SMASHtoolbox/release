function varargout=process(object,ProcessFcn,time)

% manage input
if (nargin < 2) || isempty(ProcessFcn) || strcmpi(ProcessFcn,'weighted')
    ProcessFcn=@weightBlocks;
else
    
end

if (nargin < 3) || isempty(time)
    time=uniquetol(object.MappedData(:,1));
else
    
end

%
data=object.MappedData;
data=data(data(:,6),1:4);
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