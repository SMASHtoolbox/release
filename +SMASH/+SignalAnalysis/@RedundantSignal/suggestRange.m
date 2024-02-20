% suggestRange Suggest measurement ranges
%
% This method suggest measurement ranges for specified source bound using
% the current parameter state.
%    range=suggestRange(object,bound);
% The input "bound" must be a two-element arry defining the maximumim and
% minimum values of the source signal.  The output "range" is a two-column
% table of min/max values for each measurement.
%
% The default suggestion interleaves the measurements across the source
% bound, accounting for measurement scaling/shifting.  Specifying a third
% argument:
%    range=suggestRange(object,bound,configuration);
% controls the suggested configuration.
%    -'interleave' is the default value.
%    -'bottom', 'center', and 'top' stagger measurements relative to
%    the source bound.  
% All measurements start at the lower bound for 'bottom' configuration;
% maximum values increase until last measurement reaches the upper bound.
% 'top' configuration is the exact opposite of 'bottom': all measurements
% start at the upper bound and sequentially span downward to the lower
% bound. 'middle' configuration centers all measurements on the source
% bound with symmetrically increasing ranges.
%
% Interleaved ranges overlap one another by 10%.  Alternate values may be
% specified with a fourth input.
%    range=suggestRange(object,bound,configuration,overlap);
% The input "overlap" must be greater than 0 and less than or equal to 1.
%
% NOTE: suggestions may not represent valid measurement ranges in an actual
% recording sytem!
%
% See also RedundantSignal
%

%
% created February 2, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function range=suggestRange(object,bound,configuration,overlap)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(isnumeric(bound) && (numel(bound) == 2),'ERROR: invalid source bound');
bound=sort(bound);
assert(diff(bound) > 0,'ERROR: invalid source bound');

if (nargin < 3) || isempty(configuration)
    configuration='interleave';
else
    assert(ischar(configuration),'ERROR: invalid configuration');
end

if (nargin < 4) || isempty(overlap)
    %overlap=0.10;
    overlap=0.25;
else
    assert(isnumeric(overlap) && isscalar(overlap) && (overlap > 0) && (overlap <= 1),...
        'ERROR: invalid overlap');
end

% calculate source ranges
span=bound(2)-bound(1);
range=nan(object.NumberSignals,2);
switch lower(configuration)
    case 'interleave'
        M=object.NumberSignals;
        forward=span*(1+(M-1)*overlap)/M;
        backward=overlap*span;
        for m=1:object.NumberSignals
            if m == 1
                range(m,1)=bound(1);
            else
                range(m,1)=range(m-1,2)-backward;
            end
            range(m,2)=range(m,1)+forward;
        end
    case 'bottom'
        range(:,1)=bound(1);
        for m=1:object.NumberSignals
            range(m,2)=range(m,1)+span/pow2(m-1);
        end
    case 'center'
        center=(bound(1)+bound(2))/2;
        for m=1:object.NumberSignals
            shift=span/pow2(m-1)/2;
            range(m,1)=center-shift;
            range(m,2)=center+shift;
        end
    case 'top'
        range(:,2)=bound(2);
        for m=1:object.NumberSignals
            range(m,1)=range(m,2)-span/pow2(m-1);
        end        
    otherwise
        error('ERROR: "%s" is not a valid configuration',configuration);
end

% transform source ranges to measurement ranges
for m=1:object.NumberSignals
    range(m,:)=range(m,:)*object.Parameter(m,2)+object.Parameter(m,3);
end

end