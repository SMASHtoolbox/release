% UNDER CONSTRUCTION
%
%    disable(object,name,value,...);
% Valid options include:
%    -'Index'
%    -'Time', [t1 t2]
%    -'Frequency', [f1 f2]
%    -'Polygon', [t1 f1; t2 f2; ...]
%    -'SNR', 
%    -'Uncertainty', 
%
function disable(object,varargin)

% manage arrays
N=numel(object);
if N > 1
    for n=1:N
        disable(object(n),varargin{:});
        return
    end    
end

% manage input
option=struct('Index',0,'Time',[-inf +inf]);
option=SMASH.Developer.options2struct(option,varargin{:});

end