% SMOOTH Smooth the Image data over a local neighborhood
%
% Usage:
%   >> object=smooth(object,choice,value);
% "choice" can be 'mean', 'median', or 'kernel' (advanced users only)
% "value" is the smoothing neighborhood (e.g., [3 3]) or kernel weights.
%
% NOTE: neighborhoods and kernel arrays follow MATLAB image conventions.
% For example, the first column of a neighboard array refers to the
% *vertical* vertical smoothing: [11 5] indicates smoothing over 11
% vertical points and 5 horizontal points.
%
% See also IMAGE, bin, sharpen

% created July 27, 2012 by Daniel Dolan (Sandia National Laboratories)
% minor bug fixes on February 4, 2013 by Daniel Dolan
%   -corrected kernel normalization for mean filter
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function object=smooth(object,choice,value)

% verify uniform grid
object=makeGridUniform(object);

% handle input
assert(nargin>=3,'ERROR: smoothing choice and value are required');

% apply smoothing choice
switch lower(choice)
    case 'mean'
        N=numel(value);
        if N==1
            value=repmat(value,[1 2]);
        elseif N==2
            % do nothing
        else
            error('ERROR: invalid mean smoothing size');
        end
        if any(round(value)~=value) || any(value<1) || any(N>size(object.Data))
            error('ERROR: invalid mean smoothing size');
        end
        kernel=ones(value);
        kernel=kernel/sum(kernel(:));
        object=smooth(object,'kernel',kernel);
    case 'median'
        object.Data=localmedian(object.Data,value);
    case 'kernel'
        if ~ismatrix(value)
            error('ERROR: invalid smoothing kernel');
        end
        object.Data=conv2(object.Data,value,'same');
    otherwise
        error('ERROR: invalid smoothing choice');
end

object=updateHistory(object);

end