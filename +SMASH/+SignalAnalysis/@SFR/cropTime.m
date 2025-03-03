% cropTime Crop time base
%
% This method crops the measurement time base to a specified bound.
%    cropTime(object,bound); 
% The input "bound" must be a two-element array [left right] of non-zero
% width.  Specifying -inf for the left bound implies the first measurement
% time, and specifying +inf for the right bound implies the last
% measurement time.
%
% Calling this method without a second input:
%    cropTime(object);
% allows the bound to be interactively selected.  A new figure with signal
% amplitudes is displayed for bound selection.  Closing this figure
% without pressing the "Done" button cancels the time crop.
%
% Amplitude, preview, and reduction time bases are automatically cropped
% for consistency with the measurement time base.  Region selections are
% *not* cropped.
%
% See also SFR, scaleTime, shiftTime
%
function cropTime(object,varargin)

% manual mode
if (nargin == 2) && isnumeric(varargin{1}) && (numel(varargin{1}) == 2)
    bound=sort(varargin{1});
    assert(diff(bound) > 0,'ERROR: crop bound with must be > 0');
    for k=1:numel(object)
        local=bound;
        time=object(k).Time;
        local(1)=max(local(1),time(1));
        local(2)=min(local(2),time(end));
        % signal
        keep=(time >= local(1)) & (time <= local(2));
        assert(sum(keep) > 0,'ERROR: crop region contains no data');
        time=time(keep);
        object(k).StartTime=time(1);
        signal=object(k).Signal;
        object(k).Signal=signal(keep);
        % results
        object(k).PrivateAmplitude=applyCrop1(object(k).PrivateAmplitude);
        object(k).Preview=applyCrop2(object(k).Preview);
        object(k).Reduction=applyCrop2(object(k).Reduction);
    end
    return
end
    function data=applyCrop1(data)
        if isempty(data)
            return
        end
        t=data(:,1);
        keep=(t >= local(1)) & (t <= local(2));
        data=data(keep,:);
    end
    function data=applyCrop2(data)
        for kk=1:numel(data)
            temp=data(kk).Data;
            t=temp(:,1);
            keep=(t >= local(1)) & (t <= local(2));
            temp=temp(keep,:);
            data(kk).Data=temp;
        end
    end

% interactive mode
N=numel(object);
temp=cell(N,1);
for k=1:N
    if isempty(object(k).PrivateAmplitude)
        estimateAmplitude(object(k));
    end
    data=object(k).PrivateAmplitude;    
    temp{k}=SMASH.SignalAnalysis.SignalGroup(data(:,1),data(:,2));
end
temp=gather(temp{:});
try
    temp=crop(temp);
catch
    fprintf('SFR crop cancelled\n');
    return
end

for k=1:numel(object)
    if numel(temp(k).Grid) == size(object(k).PrivateAmplitude,1)
        continue
    end
    bound=temp(k).Grid([1 end]);
    bound(1)=bound(1)-object(k).FullTime/2;
    bound(2)=bound(2)+object(k).FullTime/2;
    cropTime(object(k),bound);
end

end