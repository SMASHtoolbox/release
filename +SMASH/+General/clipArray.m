% clipArray Remove clipped values from an array
%
% This function removes clipped values from an array of arbitrary
% size/shape.  The valid data range can be specified explicitly:
%    out=clipArray(in,'Range',range);
% where "range" is a two-column array.  All values from numeric array "in"
% within this range are passed to the array "out", while values outside
% this range are replaced with NaN.
%
% Clipping range can be determined automatically from repeated
% minimum/maximum values that match a specified size.
%    out=clipArray(in,'Repeat',repeat);
% The input "repeat" indicates the number of repetitions needed to
% identify clipping.  The repeat value can be an array consistent with the
% dimensions of "in" or a scalar (same patter for all non-singleton
% dimensions).  Requesting a second output:
%    [out,range]=clipArray('Repeat',repeat);
% returns the range determined from repeat analysis.  NOTE: infinite range
% values indicate that clipping was not detected for the specified pattern.
% 
% See also SMASH.General
%

%
% created May 9, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function [array,range]=clipArray(array,mode,value)

% manage input
assert(nargin == 3,'ERROR: invalid number of inputs');
assert(isnumeric(array),'ERROR: invalid array');
assert(~any(isnan(array(:))),'ERROR: input array cannot have NaN entries');

assert(ischar(mode),'ERROR: invalid analysis mode');

assert(isnumeric(value),'ERROR: invalid analysis value');

% identify clipping
switch lower(mode)
    case 'range' 
        % manage input
        errmsg='ERROR: invalid clip range';
        assert(numel(value) == 2,errmsg);
        value=sort(value);
        assert(diff(value) > 0,errmsg);
        range=value;
        % applay range
        index=(array < range(1)) | (array > range(2));
        array(index)=nan;        
    case 'repeat'
        % manage input
        assert(all(value == round(value)) && all(value > 0),...
            'ERROR: invalid repeat array')
        L=size(array);
        if isscalar(value)
            repeat=nan(size(L));
            for k=1:numel(L)
                if L(k) == 1
                    repeat(k)=1;
                else
                    assert(L(k) > value,'ERROR: repeat too large for this array');
                    repeat(k)=value;
                end
            end
        else
            repeat=value;
            for k=1:numel(L)
                if repeat(k) < L(k)
                    continue
                elseif (repeat(k) == 1) && (L(k) == 1)
                    continue
                end
                error('ERROR: repeat too large for this array');
            end
        end 
        % determine range
        range=[-inf +inf];
        kernel=ones(repeat);
        extreme=min(array(:));
        index=(array == extreme);
        temp=convn(index,kernel,'same');
        if max(temp(:)) == prod(repeat)
            range(1)=extreme;
        end
        extreme=max(array(:));
        index=(array == extreme);
        temp=convn(index,kernel,'same');
        if max(temp(:)) == prod(repeat)
            range(2)=extreme;
        end
        % apply range
        index=(array <= range(1)) | (array >= range(2));
        array(index)=nan;
    otherwise
        error('ERROR: invalid clip mode');
end

end