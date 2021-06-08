%function filtSignal = FilterSignal(rawSignal, filterType, filterParams)
function [signal,params]=FilterSignal(rawsignal,name,params)
%FILTERSIGNAL Applies the specified filter with the given parameters.
%   Applies a filter to the raw signal data based on the filter name and
%   the corresponding parameters. Returns the filtered signal.

% Check that the raw signal is a vector
% if ~isvector(rawSignal)
%    error('ERROR: FilterSignal - Raw signal is not a vector.');
% end

% input check
if nargin<1
    rawsignal=[];
end
if nargin<2
    name=[];
end
if nargin<3
    params=[];
end

% default values
if isempty(name)
    name='none'; 
end

% error checks
if ~ischar(name)
    error('ERROR: FilterSignal - Filter name is not a string.');
end
%if ~isnumeric(params)
%    error('ERROR: FilterSignal- Filter parameters are not numeric.');
%end
    
% Apply the filter based on the name
switch lower(name)
    case 'mean'
        if isempty(params) % default parameter
            params=3;
        end
        if isempty(rawsignal)
            signal=[];
        else
            kernel=ones(params,1);
            kernel=kernel/sum(kernel);
            signal=conv2(rawsignal(:), kernel(:),'same');
        end
    case 'median'
        if isempty(params) % default parameter
            params=3;
        end
        if isempty(rawsignal)
            signal=[];
        else
            signal=medfilt1(rawsignal(:), params(1));
        end
    case 'convolution'
        if isempty(params) % default parameters
            params=[1 1 1];
        end
        kernel=params/sum(params); % normalization
        if isempty(rawsignal)
            signal=[];
        else
            signal=conv2(rawsignal(:),kernel(:),'same');
        end 
    case 'savitsky-golay'
        % under construction
    case {'','none'} % do nothing, no filtering needed
        signal = rawsignal;
    otherwise
        error('ERROR: FilterSignal - Unknown filter name.');
end
signal=reshape(signal,size(rawsignal));