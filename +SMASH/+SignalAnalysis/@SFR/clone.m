% clone Create independent copy
%
% This method creates an independent copy of an SFR object.
%    new=clone(object);
% The output "new" contains the same information as "object", but changes
% to one do *not* translate to the other.
%
% See also SFR
%
function new=clone(object)

name={'Name' 'RiseTime' 'StepTime' 'PeakPoints' 'FrequencyBand'...
    'Window' 'Noise' 'Preview' 'Selection' 'Reduction' 'Colormap'};
N=numel(name);

M=numel(object);
new=cell(1,M);

for m=1:M
    new{m}=packtools.call('SFR',object(m).Time,object(m).Signal);
    for n=1:N
        new{m}.(name{n})=object(m).(name{n});
    end         
end

new=[new{:}];

end